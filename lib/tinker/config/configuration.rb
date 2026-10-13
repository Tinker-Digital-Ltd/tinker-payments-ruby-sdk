# frozen_string_literal: true

module Tinker
  module Config
    class Configuration
      attr_reader :api_public_key, :api_secret_key, :base_url, :auth_url

      def initialize(api_public_key:, api_secret_key:, base_url: nil)
        @api_public_key = api_public_key
        @api_secret_key = api_secret_key

        resolved_base_url = base_url
        if resolved_base_url.nil? || resolved_base_url.strip.empty?
          resolved_base_url = sandbox_credentials? ? Endpoints::SANDBOX_BASE_URL : Endpoints::PRODUCTION_BASE_URL
        end

        resolved_base_url = resolved_base_url.chomp('/')
        unless resolved_base_url.end_with?(Endpoints::API_VERSION_PATH)
          resolved_base_url = "#{resolved_base_url}#{Endpoints::API_VERSION_PATH}"
        end

        @base_url = "#{resolved_base_url}/"
        @auth_url = "#{resolved_base_url}#{Endpoints::AUTH_TOKEN_PATH}"
      end

      def api_key
        @api_secret_key
      end

      private

      def sandbox_credentials?
        @api_public_key.start_with?('pk_test_') || @api_secret_key.start_with?('sk_test_')
      end
    end
  end
end
