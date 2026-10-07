# Run with brew ruby rebuild-bottle.rb FORMULA.
# Homebrew 7 reinstall CLI does not expose --build-bottle.
require "formula"
require "formula_installer"
require "install"
require "reinstall"
name = ARGV.fetch(0)
f = Formula[name]
keg = f.opt_prefix.directory? ? Keg.new(f.opt_prefix.realpath) : nil
installer = FormulaInstaller.new(f, build_bottle: true, verbose: true,
  installed_on_request: keg ? keg.tab.installed_on_request == true : true,
  link_keg: keg ? keg.linked? : !f.keg_only?)
Homebrew::Install.perform_preinstall_checks_once
valid = Homebrew::Install.fetch_formulae([installer])
raise "Source fetch failed" unless valid.include?(installer)
context = Homebrew::Reinstall::InstallationContext.new(
 formula_installer: installer, keg: keg, formula: f,
 options: Options.new, link_keg: keg ? keg.linked? : !f.keg_only?)
Homebrew::Reinstall.reinstall_formula(context)
