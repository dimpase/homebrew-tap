# typed: strict
# frozen_string_literal: true

# This installer is for disposable hosted CI runners, not a developer's prefix.
require "json"
require "digest"
require "cache_store"
require "linkage_checker"
require "system_command"
require "utils/bottles"
require_relative "sage-bottle-closure"
require_relative "sage-bottle-linkage"

# The workflow supplies the validation root explicitly.
artifacts = Pathname(ARGV.fetch(0))/"artifacts"
artifacts.mkpath
raise "ARM64 runner required" if Hardware::CPU.arch != :arm64

root = Formulary.factory("dimpase/tap/sagemath-deps")
raise "Published sagemath-deps 11.0.beta6_1 required" if root.pkg_version.to_s != "11.0.beta6_1"

rows = []
formulae_by_name = {}
report = { platform: Utils::Bottles.tag.to_s, root: root.full_name,
           root_version: root.pkg_version.to_s, phase: "preflight", formulae: rows }
save_report = lambda do
  (artifacts/"bottle-provenance.json").write("#{JSON.pretty_generate(report)}\n")
end
save_report.call

# Resolve the union of current recipe dependencies and dependencies recorded
# inside each selected bottle. Fetch and verify the entire fixed-point closure
# before pouring anything; preinstalled libraries must not hide missing bottles.
begin
  ordered = SageBottleClosure.resolve(root.full_name) do |requested_name|
    formula = Formulary.factory(requested_name)
    bottle = formula.bottle
    tap = formula.tap
    runtime_formula_deps = formula.deps.reject do |dependency|
      dependency.build? || dependency.test? || dependency.optional?
    end
    declared = runtime_formula_deps.map { |dependency| dependency.to_formula.full_name }
    row = {
      name: formula.full_name, version: formula.pkg_version.to_s,
      tap: tap&.name, tap_revision: (tap.git_head if tap&.installed?),
      keg: (formula.rack/formula.pkg_version.to_s).to_s,
      declared_dependencies: declared,
      dependencies: declared,
      bottle: bottle && { tag: bottle.tag.to_s, rebuild: bottle.rebuild,
                          url: bottle.url, sha256: bottle.resource.checksum.to_s }
    }
    rows << row
    formulae_by_name[formula.full_name] = formula
    save_report.call
    next row unless bottle

    SystemCommand.safe_system HOMEBREW_BREW_FILE, "fetch", "--force-bottle", "--retry", formula.full_name
    archive = bottle.cached_download
    bottle.verify_download_integrity(archive)
    receipt_path = Utils::Bottles.receipt_path(archive)
    receipt = if receipt_path
      row[:bottle_receipt_source] = "archive:#{receipt_path}"
      JSON.parse(Utils::Bottles.file_from_bottle(archive, receipt_path))
    else
      # Modern core bottles keep their tab in GHCR manifest annotations.
      # Those annotations are not authenticated by the archive checksum;
      # retain their separate origin and parsed-metadata digest below.
      bottle.fetch_tab(quiet: true)
      row[:bottle_receipt_source] = "ghcr_manifest"
      bottle.tab_attributes
    end
    raise "No runtime receipt for verified bottle: #{formula.full_name}" if receipt.empty?

    row[:bottle_receipt_json_sha256] = Digest::SHA256.hexdigest(JSON.generate(receipt))
    row[:bottle_receipt_covered_by_archive_sha256] = !receipt_path.nil?
    runtime = receipt.fetch("runtime_dependencies", nil) || []
    row[:bottle_receipt] = receipt
    row[:bottle_runtime_dependencies] = runtime
    row[:dependencies] = (declared + runtime.map { |dependency| dependency.fetch("full_name") }).uniq
    save_report.call
    row
  end
rescue => e
  report[:error] = e.message
  save_report.call
  raise
end

rows = ordered
formulae = rows.map { |row| formulae_by_name.fetch(row[:name]) }
report[:formulae] = rows
report[:phase] = "pouring"
save_report.call

formulae.zip(rows).each do |formula, row|
  puts "Pouring #{row[:name]} #{row[:version]} (#{row[:bottle][:tag]})"
  $stdout.flush
  # Reinstall preinstalled formulae through Homebrew's normal replacement path,
  # preserving bootstrap libraries until their replacement is ready. All of
  # this formula's runtime dependencies have already been poured and verified.
  # `reinstall` has no --ignore-dependencies option; `install` does.
  if formula.any_version_installed?
    SystemCommand.safe_system HOMEBREW_BREW_FILE, "reinstall", "--force-bottle", formula.full_name
  else
    SystemCommand.safe_system HOMEBREW_BREW_FILE, "install", "--force-bottle", "--ignore-dependencies",
                              formula.full_name
  end
  keg = Pathname(row[:keg])
  receipt_path = keg/"INSTALL_RECEIPT.json"
  receipt = JSON.parse(receipt_path.read)
  row[:receipt] = receipt
  save_report.call
  raise "Not poured from a bottle: #{formula.full_name}" unless receipt.fetch("poured_from_bottle")
  raise "Wrong tap: #{formula.full_name}" if receipt.dig("source", "tap") != row[:tap]
  raise "Wrong keg version: #{formula.full_name}" if formula.opt_prefix.realpath != keg.realpath
  if receipt.dig("source", "versions", "stable") != formula.version.to_s
    raise "Wrong receipt version: #{formula.full_name}"
  end
end

# Retain Homebrew's normal linkage checks, then require every actual linked keg
# to match an exact path whose poured receipt was verified above.
report[:phase] = "linkage"
save_report.call
audited_kegs = rows.to_set { |row| Pathname(row[:keg]).realpath.to_s }
begin
  formulae.zip(rows).each do |formula, row|
    row[:linkage] = SageBottleLinkage.audit(formula, audited_kegs, macos: OS.mac?)
    save_report.call
  end
rescue => e
  report[:error] = e.message
  save_report.call
  raise
end
report[:phase] = "verified"
save_report.call
puts "Verified #{rows.length} published bottles and their runtime linkage"
