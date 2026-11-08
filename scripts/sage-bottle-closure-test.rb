# typed: strict
# frozen_string_literal: true

require "minitest/autorun"
require_relative "sage-bottle-closure"

# Exercise complete planning failures without touching a Homebrew installation.
class SageBottleClosureTest < Minitest::Test
  def node(name, declared: [], runtime: [], bottle: true)
    { name: name, bottle: bottle, dependencies: (declared + runtime).uniq }
  end

  def test_receipt_only_transitive_dependencies_precede_their_consumers
    nodes = {
      "sage"        => node("sage", declared: ["library"], runtime: ["old-icu"]),
      "library"     => node("library", runtime: ["old-icu"]),
      "old-icu"     => node("old-icu", runtime: ["old-openssl"]),
      "old-openssl" => node("old-openssl"),
    }
    fetched = []
    result = SageBottleClosure.resolve("sage") do |name|
      fetched << name
      nodes.fetch(name)
    end
    assert_equal %w[old-openssl old-icu library sage], result.map { |entry| entry[:name] }
    assert_equal fetched.uniq, fetched
  end

  def test_receipt_dependency_without_bottle_rejects_the_whole_plan
    nodes = {
      "sage"        => node("sage", runtime: ["unpublished"]),
      "unpublished" => node("unpublished", bottle: false),
    }
    error = assert_raises(RuntimeError) do
      SageBottleClosure.resolve("sage") { |name| nodes.fetch(name) }
    end
    assert_match(/No compatible published bottle: unpublished/, error.message)
  end

  def test_cycles_in_mixed_recipe_and_receipt_edges_fail_with_the_path
    nodes = {
      "sage"    => node("sage", declared: ["library"]),
      "library" => node("library", runtime: ["sage"]),
    }
    error = assert_raises(RuntimeError) do
      SageBottleClosure.resolve("sage") { |name| nodes.fetch(name) }
    end
    assert_match(/sage -> library -> sage/, error.message)
  end

  def test_aliases_share_one_canonical_node_without_false_cycles
    library = node("library")
    nodes = {
      "sage"                  => node("sage", declared: ["homebrew/core/library", "library"]),
      "homebrew/core/library" => library,
      "library"               => library,
    }
    result = SageBottleClosure.resolve("sage") { |name| nodes.fetch(name) }
    assert_equal %w[library sage], result.map { |entry| entry[:name] }
  end
end
