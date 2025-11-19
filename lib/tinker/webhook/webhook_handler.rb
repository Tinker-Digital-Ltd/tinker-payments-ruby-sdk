# frozen_string_literal: true

require 'json'

module Tinker
  module Webhook
    class WebhookHandler
      def handle(payload)
        data = if payload.is_a?(String)
                 JSON.parse(payload)
               else
                 payload
               end

        raise Exception::InvalidPayloadException.new('Webhook payload must be a hash') unless data.is_a?(Hash)

        WebhookEvent.new(data)
      rescue JSON::ParserError => e
        raise Exception::InvalidPayloadException.new("Invalid JSON payload: #{e.message}")
      end

      def handle_from_request(request_body = nil)
        payload = request_body || $stdin.read
        raise Exception::WebhookException.new('Unable to read request body') if payload.nil? || payload.empty?

        handle(payload)
      end

      def handle_as_transaction(payload)
        event = handle(payload)
        event.to_transaction
      end
    end
  end
end
