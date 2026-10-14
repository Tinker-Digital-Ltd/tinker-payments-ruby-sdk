# frozen_string_literal: true

require 'json'
require 'openssl'

module Tinker
  module Webhook
    class WebhookHandler
      def handle(payload)
        data = if payload.is_a?(String)
                 JSON.parse(payload)
               else
                 payload
               end

        raise Exception::InvalidPayloadException, 'Webhook payload must be a hash' unless data.is_a?(Hash)

        WebhookEvent.new(data)
      rescue JSON::ParserError => e
        raise Exception::InvalidPayloadException, "Invalid JSON payload: #{e.message}"
      end

      def handle_from_request(request_body = nil)
        payload = request_body || $stdin.read
        raise Exception::WebhookException, 'Unable to read request body' if payload.nil? || payload.empty?

        handle(payload)
      end

      def handle_as_transaction(payload)
        event = handle(payload)
        event.to_transaction
      end

      def verify_signature(payload_or_event, webhook_secret)
        return false if webhook_secret.nil? || webhook_secret.empty?

        event = payload_or_event.is_a?(WebhookEvent) ? payload_or_event : handle(payload_or_event)
        signature = event.security.signature
        return false unless event.security.algorithm == 'HMAC-SHA256' && signature&.start_with?('sha256=')

        computed = computed_signature(event, webhook_secret)
        return false unless signature.bytesize == computed.bytesize

        OpenSSL.fixed_length_secure_compare(signature, computed)
      end

      private

      def sort_maps(value)
        case value
        when Hash
          value.keys.sort.to_h { |key| [key, sort_maps(value[key])] }
        when Array
          value.map { |item| sort_maps(item) }
        else
          value
        end
      end

      def computed_signature(event, webhook_secret)
        payload_without_security = {
          id: event.id,
          type: event.type,
          source: event.source,
          timestamp: event.timestamp,
          data: sort_maps(event.raw_data),
          meta: sort_maps(event.raw_meta)
        }

        encoded = JSON.generate(payload_without_security)
        encoded = encoded.gsub(/[<>&\u2028\u2029]/) { |char| format('\\u%04x', char.ord) }
        "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, encoded)}"
      end
    end
  end
end
