# typed: strict
# frozen_string_literal: true

# This installer is for disposable hosted CI runners, not a developer's prefix.
require "json"

artifacts = Pathname(ENV.fetch("VALIDATION_ROOT"))/"artifacts"
artifacts.mkpath
raise "ARM64 runner required" if Hardware::CPU.arch != :arm64

root = Formulary.factory("dimpase/tap/sagemath-deps")
raise "Published beta6 dependencies required" if root.version.to_s != "11.0.beta6"

# Dependency-first traversal; build-only packages are not needed to pour bottles.
formulae = []
visited = Set.new
visit = lambda do |formula|
  next unless visited.add?(formula.full_name)

  formula.deps.each do |dependency|
    next if dependency.build? || dependency.test? || dependency.optional?

    visit.call(dependency.to_formula)
  end
  formulae << formula
end
visit.call(root)

rows = formulae.map do |formula|
  bottle = formula.bottle
  tap = formula.tap
  {
    name: formula.full_name, version: formula.pkg_version.to_s,
    tap: tap&.name, tap_revision: (tap.git_head if tap&.installed?),
    keg: (formula.rack/formula.pkg_version.to_s).to_s,
    bottle: bottle && { tag: bottle.tag.to_s, rebuild: bottle.rebuild,
                        url: bottle.url, sha256: bottle.resource.checksum.to_s }
  }
end
report = { platform: Utils::Bottles.tag.to_s, root: root.full_name,
           root_version: root.pkg_version.to_s, formulae: rows }
save_report = lambda do
  (artifacts/"bottle-provenance.json").write("#{JSON.pretty_generate(report)}\n")
end
save_report.call
missing = rows.reject { |row| row[:bottle] }.map { |row| row[:name] }
raise "Missing compatible bottles: #{missing.join(", ")}" unless missing.empty?

# Download and verify everything while the runner's existing tools are intact.
formulae.each do |formula|
  safe_system HOMEBREW_BREW_FILE, "fetch", "--force-bottle", "--retry", formula.full_name
end

formulae.zip(rows).each do |formula, row|
  puts "Pouring #{row[:name]} #{row[:version]} (#{row[:bottle][:tag]})"
  $stdout.flush
  # Reinstall preinstalled formulae through Homebrew's normal replacement path,
  # preserving bootstrap libraries until their replacement is ready. All of
  # this formula's runtime dependencies have already been poured and verified.
  # `reinstall` has no --ignore-dependencies option; `install` does.
  if formula.any_version_installed?
    safe_system HOMEBREW_BREW_FILE, "reinstall", "--force-bottle", formula.full_name
  else
    safe_system HOMEBREW_BREW_FILE, "install", "--force-bottle", "--ignore-dependencies", formula.full_name
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

# Check the entire installed closure, not just sagemath-deps' Python extensions.
formulae.each do |formula|
  safe_system HOMEBREW_BREW_FILE, "linkage", "--test", formula.full_name
end
puts "Verified #{rows.length} published bottles and their runtime linkage"
