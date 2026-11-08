# typed: strict
# frozen_string_literal: true

# Build a dependency-first plan before the caller performs any installations.
# The loader supplies both current formula dependencies and fetched bottle
# runtime dependencies, including dependencies no longer declared by a formula.
module SageBottleClosure
  def self.resolve(root_name)
    nodes = {}
    active = []
    finished = {}
    ordered = []
    visit = lambda do |requested_name|
      node = nodes[requested_name] ||= yield(requested_name)
      name = node.fetch(:name)
      nodes[name] ||= node
      next if finished[name]

      raise "No compatible published bottle: #{name}" unless node[:bottle]

      if active.include?(name)
        raise "Bottle dependency cycle: #{(active + [name]).join(" -> ")}"
      end

      active << name
      node.fetch(:dependencies).each { |dependency| visit.call(dependency) }
      active.pop
      finished[name] = true
      ordered << node
    end
    visit.call(root_name)
    ordered
  end
end
