# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module Tinker
  module Http
    class HttpClient
      def initialize
        @timeout = 30
      end

      def get(url, headers: {})
        request(url, Net::HTTP::Get, headers: headers)
      end

      def post(url, headers: {}, body: nil)
        request(url, Net::HTTP::Post, headers: headers, body: body)
      end

      private

      def request(url, request_class, headers:, body: nil)
        uri = URI(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        http.read_timeout = @timeout
        http.open_timeout = @timeout

        path = uri.path
        path += "?#{uri.query}" if uri.query
        req = request_class.new(path)
        headers.each { |key, value| req[key] = value }
        req.body = body if body

        response = http.request(req)
        Response.new(response.code.to_i, response.body, response.to_hash)
      rescue StandardError => e
        raise Exception::NetworkException.new("Network error: #{e.message}", Exception::ExceptionCode::NETWORK_ERROR, e)
      end

      class Response
        attr_reader :status_code, :body, :headers

        def initialize(status_code, body, headers)
          @status_code = status_code
          @body = body
          @headers = headers
        end

        def json
          JSON.parse(@body)
        rescue JSON::ParserError => e
          raise Exception::InvalidPayloadException.new("Invalid JSON response: #{e.message}", Exception::ExceptionCode::INVALID_PAYLOAD)
        end
      end
    end
  end
end
