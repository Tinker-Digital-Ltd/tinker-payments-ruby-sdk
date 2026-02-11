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
        response = method.to_s.upcase == 'GET' ? @http_client.get(url, headers: headers) : @http_client.post(url, headers: headers, body: body)
        result = response.json

        if response.status_code >= 400
          raise Exception::ApiException.new(extract_error_message(result), Exception::ExceptionCode::API_ERROR)
        end

        if result.is_a?(Hash) && result.key?('success')
          @last_meta = Model::ApiMeta.new(result['meta'] || {})
          if result['success'] == false
            raise Exception::ApiException.new(extract_error_message(result), Exception::ExceptionCode::API_ERROR)
          end

          data_payload = result['data']
          return data_payload.is_a?(Hash) ? data_payload : { 'value' => data_payload }
        end

        result || {}
      rescue Exception::ApiException => e
        raise e
      rescue StandardError => e
        raise Exception::NetworkException.new("Failed to communicate with Tinker API: #{e.message}",
                                              Exception::ExceptionCode::NETWORK_ERROR, e)
      end

      def extract_error_message(result)
        if result.is_a?(Hash)
          error = result['error']
          if error.is_a?(Hash)
            return error['message'] || error['code'] || 'Unknown error'
          end
          return result['message'] || 'Unknown error'
        end
        'Unknown error'
      end
    end
  end
end
