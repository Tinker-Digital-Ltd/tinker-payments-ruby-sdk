# frozen_string_literal: true

require 'base64'
require 'uri'
require 'json'

module Tinker
  module Auth
    class AuthenticationManager
      attr_reader :last_meta

      def initialize(config:, http_client:)
        @config = config
        @http_client = http_client
        @token = nil
        @expires_at = nil
        @last_meta = nil
      end

      def token
        return @token if token_valid?

        fetch_token
      end

      private

      def token_valid?
        return false if @token.nil? || @expires_at.nil?

        Time.now.to_i < (@expires_at - 60)
      end

      def fetch_token
        credentials = Base64.strict_encode64("#{@config.api_public_key}:#{@config.api_secret_key}")

        headers = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Accept' => 'application/json'
        }
        body = "credentials=#{URI.encode_www_form_component(credentials)}"

        response = @http_client.post(@config.auth_url, headers: headers, body: body)
        result = response.json
        auth_data = extract_auth_data(result)

        if response.status_code >= 400
          raise Exception::AuthenticationException.new(extract_error_message(result), Exception::ExceptionCode::AUTHENTICATION_ERROR)
        end

        unless auth_data['token']
          raise Exception::NetworkException.new('Invalid authentication response: token missing', Exception::ExceptionCode::AUTHENTICATION_ERROR)
        end

        @token = auth_data['token']
        expires_in = auth_data['expires_in'] || 3600
        @expires_at = Time.now.to_i + expires_in

        @token
      rescue Exception::AuthenticationException, Exception::NetworkException => e
        raise e
      rescue StandardError => e
        raise Exception::NetworkException.new("Failed to authenticate: #{e.message}",
                                              Exception::ExceptionCode::AUTHENTICATION_ERROR, e)
      end

      def extract_auth_data(result)
        if result.is_a?(Hash) && result.key?('success')
          @last_meta = Model::ApiMeta.new(result['meta'] || {})
          if result['success'] == false
            raise Exception::AuthenticationException.new(extract_error_message(result), Exception::ExceptionCode::AUTHENTICATION_ERROR)
          end

          return result['data'].is_a?(Hash) ? result['data'] : {}
        end

        result.is_a?(Hash) ? result : {}
      end

      def extract_error_message(result)
        if result.is_a?(Hash)
          error = result['error']
          return error['message'] || error['code'] || 'Authentication failed' if error.is_a?(Hash)

          return result['message'] || 'Authentication failed'
        end
        'Authentication failed'
      end
    end
  end
end
