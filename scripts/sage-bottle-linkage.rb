# typed: strict
# frozen_string_literal: true

require "json"

# Verify actual shared-library owners, including libraries omitted by recipes.
module SageBottleLinkage
  def self.system_library?(library, macos:)
    path = Pathname(library)
    return false unless path.absolute?

    path = path.exist? ? path.realpath.to_s : path.cleanpath.to_s
    roots = macos ? %w[/usr/lib /System/Library] : %w[/lib /lib64 /usr/lib /usr/lib64]
    roots.any? { |root| path.start_with?("#{root}/") }
  end

  def self.audit(formula, audited_kegs, macos:)
    keg = Keg.new(formula.opt_prefix.realpath)
    CacheStoreDatabase.use(:linkage) do |database|
      checker = LinkageChecker.new(keg, formula, cache_db: database, rebuild_cache: true)
      checker.display_test_output
      raise "Broken linkage: #{formula.full_name}" if checker.broken_library_linkage?(test: true)
    end

    # Close/reopen to serialize the freshly rebuilt cache. In current Homebrew,
    # the writer uses symbol keys while the reader expects JSON string keys.
    owners = Set.new
    system_libraries = Set.new
    CacheStoreDatabase.use(:linkage) do |database|
      entries = LinkageCacheStore.new(keg.to_s, database).fetch(:keg_files_dylibs)
      raise "Missing refreshed linkage data: #{keg}" unless entries.is_a?(Hash)

      entries.each do |file, libraries|
        libraries.each do |library|
          raise "Unresolved library: #{file} -> #{library}" if library.start_with?("@")

          begin
            owner = Keg.for(Pathname(library))
          rescue NotAKegError, Errno::ENOENT
            unless system_library?(library, macos: macos)
              raise "Unexpected external library: #{file} -> #{library}"
            end

            system_libraries << library
            next
          end

          owner_path = Pathname(owner.to_s).realpath.to_s
          unless audited_kegs.include?(owner_path)
            raise "Unaudited keg: #{file} -> #{library} (#{owner_path})"
          end

          receipt = JSON.parse((Pathname(owner_path)/"INSTALL_RECEIPT.json").read)
          raise "Source-built keg: #{owner_path}" unless receipt.fetch("poured_from_bottle")

          owners << owner_path
        end
      end
    end
    { linked_kegs: owners.to_a.sort, system_libraries: system_libraries.to_a.sort }
  end
end
