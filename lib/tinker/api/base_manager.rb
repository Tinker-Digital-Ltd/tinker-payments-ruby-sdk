# frozen_string_literal: true

require 'json'

module Tinker
  module Api
    class BaseManager
      attr_reader :last_meta

      def initialize(config:, http_client:, auth_manager:)
        @config = config
        @http_client = http_client
        @auth_manager = auth_manager
        @last_meta = nil
      end

      protected

      def request(method, endpoint, data = {})
        base_url = @config.base_url.chomp('/')
        endpoint = endpoint[1..] if endpoint.start_with?('/')
        url = "#{base_url}/#{endpoint}"

        token = @auth_manager.token
        headers = {
          'Authorization' => "Bearer #{token}",
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }

        body = data.nil? || data.empty? ? nil : JSON.generate(data)
        response = send_request(method, url, headers, body)
        result = decode_response(response)
        raise api_error(response, result) if response.status_code >= 400

        unwrap_response(response, result)
      rescue Exception::ApiException => e
        raise e
      rescue StandardError => e
        raise Exception::NetworkException.new("Failed to communicate with Tinker API: #{e.message}",
                                              Exception::ExceptionCode::NETWORK_ERROR, e)
      end

      def send_request(method, url, headers, body)
        return @http_client.get(url, headers: headers) if method.to_s.upcase == 'GET'

        @http_client.post(url, headers: headers, body: body)
      end

      def decode_response(response)
        response.json
      rescue Exception::InvalidPayloadException
        raise if response.status_code < 400

        {}
      end

      def unwrap_response(response, result)
        return result || {} unless result.is_a?(Hash) && result.key?('success')

        @last_meta = Model::ApiMeta.new(result['meta'] || {})
        raise api_error(response, result) if result['success'] == false

        data = result['data']
        data.is_a?(Hash) ? data : { 'value' => data }
      end

      def api_error(response, result)
        Exception::ApiException.new(extract_error_message(result), http_status: response.status_code,
                                                                   details: result, headers: response.headers || {})
      end

      def extract_error_message(result)
        if result.is_a?(Hash)
          error = result['error']
          return error['message'] || error['code'] || 'Unknown error' if error.is_a?(Hash)

          return result['message'] || 'Unknown error'
        end
        'Unknown error'
      end
    end
  end
end
