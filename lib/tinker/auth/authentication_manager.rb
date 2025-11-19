# frozen_string_literal: true

require 'base64'
require 'uri'
require 'json'

module Tinker
  module Auth
    class AuthenticationManager
      def initialize(config:, http_client:)
        @config = config
        @http_client = http_client
        @token = nil
        @expires_at = nil
      end

      def get_token
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

        url = Config::Endpoints::AUTH_TOKEN_URL
        headers = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Accept' => 'application/json'
        }
        body = "credentials=#{URI.encode_www_form_component(credentials)}"

        response = @http_client.post(url, headers: headers, body: body)
        result = response.json

        if response.status_code >= 400
          message = result['message'] || 'Authentication failed'
          raise Exception::AuthenticationException.new(message, Exception::ExceptionCode::AUTHENTICATION_ERROR)
        end

        unless result['token']
          raise Exception::NetworkException.new('Invalid authentication response: token missing', Exception::ExceptionCode::AUTHENTICATION_ERROR)
        end

        @token = result['token']
        expires_in = result['expires_in'] || 3600
        @expires_at = Time.now.to_i + expires_in

        @token
      rescue Exception::AuthenticationException, Exception::NetworkException => e
        raise e
      rescue StandardError => e
        raise Exception::NetworkException.new("Failed to authenticate: #{e.message}",
                                              Exception::ExceptionCode::AUTHENTICATION_ERROR, e)
      end
    end
  end
end
