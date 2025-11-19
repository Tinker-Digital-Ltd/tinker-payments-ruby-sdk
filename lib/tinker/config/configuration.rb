# frozen_string_literal: true

module Tinker
  module Config
    class Configuration
      attr_reader :api_public_key, :api_secret_key, :base_url

      def initialize(api_public_key:, api_secret_key:)
        @api_public_key = api_public_key
        @api_secret_key = api_secret_key
        @base_url = "#{Endpoints::API_BASE_URL}/"
      end

      def api_key
        @api_secret_key
      end
    end
  end
end
