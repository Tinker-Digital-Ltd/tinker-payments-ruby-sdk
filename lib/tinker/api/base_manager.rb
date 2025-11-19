# frozen_string_literal: true

require 'json'

module Tinker
  module Api
    class BaseManager
      def initialize(config:, http_client:, auth_manager:)
        @config = config
        @http_client = http_client
        @auth_manager = auth_manager
      end

      protected

      def request(_method, endpoint, data = {})
        base_url = @config.base_url.chomp('/')
        endpoint = endpoint[1..] if endpoint.start_with?('/')
        url = "#{base_url}/#{endpoint}"

        token = @auth_manager.token
        headers = {
          'Authorization' => "Bearer #{token}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }

        body = data.empty? ? nil : JSON.generate(data)

        response = @http_client.post(url, headers: headers, body: body)
        result = response.json

        if response.status_code >= 400
          message = result.is_a?(Hash) ? (result['message'] || result['error'] || 'Unknown error') : 'Unknown error'
          raise Exception::ApiException.new(message, Exception::ExceptionCode::API_ERROR)
        end

        result || {}
      rescue Exception::ApiException => e
        raise e
      rescue StandardError => e
        raise Exception::NetworkException.new("Failed to communicate with Tinker API: #{e.message}",
                                              Exception::ExceptionCode::NETWORK_ERROR, e)
      end
    end
  end
end
