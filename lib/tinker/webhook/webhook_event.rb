# frozen_string_literal: true

module Tinker
  module Webhook
    class WebhookEvent
      attr_reader :id, :type, :source, :timestamp, :data, :meta, :security

      def initialize(payload)
        @id = payload['id']
        @type = payload['type']
        @source = payload['source']
        @timestamp = payload['timestamp']
        @data = create_event_data(payload['data'], @source)
        @meta = WebhookMeta.new(payload['meta'] || {})
        @security = WebhookSecurity.new(payload['security'] || {})
      end

      def payment_event?
        @source == 'payment'
      end

      def subscription_event?
        @source == 'subscription'
      end

      def invoice_event?
        @source == 'invoice'
      end

      def settlement_event?
        @source == 'settlement'
      end

      def get_payment_data
        @data.is_a?(Dto::PaymentEventDataDto) ? @data : nil
      end

      def get_subscription_data
        @data.is_a?(Dto::SubscriptionEventDataDto) ? @data : nil
      end

      def get_invoice_data
        @data.is_a?(Dto::InvoiceEventDataDto) ? @data : nil
      end

      def get_settlement_data
        @data.is_a?(Dto::SettlementEventDataDto) ? @data : nil
      end

      def to_transaction
        return nil unless payment_event?
        return nil unless @data.is_a?(Dto::PaymentEventDataDto)

        Model::Transaction.new(@data.to_hash)
      end

      private

      def create_event_data(data, source)
        case source
        when 'payment'
          Dto::PaymentEventDataDto.new(data)
        when 'subscription'
          Dto::SubscriptionEventDataDto.new(data)
        when 'invoice'
          Dto::InvoiceEventDataDto.new(data)
        when 'settlement'
          Dto::SettlementEventDataDto.new(data)
        else
          raise Exception::InvalidPayloadException.new("Unknown webhook source: #{source}", Exception::ExceptionCode::INVALID_PAYLOAD)
        end
      end
    end
  end
end
