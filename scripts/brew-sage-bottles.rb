# typed: strict
# frozen_string_literal: true

# Run inside Homebrew's initialized process to preserve its platform defaults.
require "api"
require "formulary"

Homebrew::API.fetch_api_files! unless Homebrew::EnvConfig.no_install_from_api?
require_relative "sage-bottles"
