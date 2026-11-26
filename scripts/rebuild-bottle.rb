# typed: strict
# frozen_string_literal: true

# Run with brew ruby rebuild-bottle.rb FORMULA.
# Homebrew 7 reinstall CLI does not expose --build-bottle.
require "formula"
require "formula_installer"
require "install"
require "reinstall"
name = ARGV.fetch(0)
f = Formula[name]
keg = Keg.new(f.opt_prefix.realpath) if f.opt_prefix.directory?
installed_on_request = if keg
  keg.tab.installed_on_request == true
else
  true
end
link_keg = if keg
  keg.linked?
else
  !f.keg_only?
end
installer = FormulaInstaller.new(f, build_bottle: true, verbose: true,
  installed_on_request: installed_on_request,
  link_keg: link_keg)
Homebrew::Install.perform_preinstall_checks_once
valid = Homebrew::Install.fetch_formulae([installer])
raise "Source fetch failed" unless valid.include?(installer)

link_keg = if keg
  keg.linked?
else
  !f.keg_only?
end
context = Homebrew::Reinstall::InstallationContext.new(
  formula_installer: installer, keg: keg, formula: f,
  options: Options.new, link_keg: link_keg
)
Homebrew::Reinstall.reinstall_formula(context)
