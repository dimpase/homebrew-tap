# typed: strict
# frozen_string_literal: true

require "minitest/autorun"
# Standalone tests do not load Homebrew's shared Ruby environment.
require "pathname" # rubocop:disable Lint/RedundantRequireStatement
require_relative "sage-bottle-linkage"

# OS library exceptions must not permit arbitrary external native dependencies.
class SageBottleLinkageTest < Minitest::Test
  def test_platform_library_roots
    assert SageBottleLinkage.system_library?("/usr/lib/libSystem.B.dylib", macos: true)
    assert SageBottleLinkage.system_library?("/System/Library/Frameworks/Example.framework/Example", macos: true)
    assert SageBottleLinkage.system_library?("/lib/aarch64-linux-gnu/libc.so.6", macos: false)
    assert SageBottleLinkage.system_library?("/usr/lib64/libc.so.6", macos: false)
  end

  def test_external_paths_and_prefix_escapes_are_rejected
    %w[/usr/local/lib/libsource.so /home/runner/lib/libsource.so /usr/lib/../../tmp/libsource.so
       /usr/library/libsource.so @rpath/libsource.dylib].each do |path|
      refute SageBottleLinkage.system_library?(path, macos: true), path
      refute SageBottleLinkage.system_library?(path, macos: false), path
    end
  end
end
