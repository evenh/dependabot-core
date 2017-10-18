# frozen_string_literal: true

require "excon"
require "dependabot/metadata_finders/base"
require "dependabot/shared_helpers"

module Dependabot
  module MetadataFinders
    module Elixir
      class Hex < Dependabot::MetadataFinders::Base
        SOURCE_KEYS = %w(
          GitHub
          Github
          github
          Source
          source
        ).freeze

        private

        def look_up_source
          potential_source_urls =
            SOURCE_KEYS.
            map { |key| hex_listing.dig("meta", "links", key) }.
            compact

          source_url = potential_source_urls.find { |url| url =~ SOURCE_REGEX }

          return nil unless source_url
          source_url.match(SOURCE_REGEX).named_captures
        end

        def hex_listing
          return @hex_listing unless @hex_listing.nil?

          response = Excon.get(
            "https://hex.pm/api/packages/#{dependency.name}",
            idempotent: true,
            middlewares: SharedHelpers.excon_middleware
          )

          @hex_listing = JSON.parse(response.body)
        end
      end
    end
  end
end
