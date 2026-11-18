# frozen_string_literal: true

module Tinker
  module Webhook
    class WebhookEvent
      attr_reader :id, :type, :source, :timestamp, :data, :meta, :security, :raw_data, :raw_meta

      def initialize(payload)
        @id = payload['id']
        @type = payload['type']
        @source = payload['source']
        @timestamp = payload['timestamp']
        @raw_data = payload['data'].is_a?(Hash) ? payload['data'] : {}
        @raw_meta = payload['meta'].is_a?(Hash) ? payload['meta'] : {}
        @data = create_event_data(@raw_data, @source)
        @meta = WebhookMeta.new(@raw_meta)
        @security = WebhookSecurity.new(payload['security'] || {})
      end

      def onboarding_event?
        @source == 'onboarding'
      end

      # Verify the signature before acknowledging a setup test.
      def setup_test?
        onboarding_event? && @type == 'setup.webhook_test'
      end

      def onboarding_data
        @data.is_a?(Dto::OnboardingEventDataDto) ? @data : nil
      end

      def cancellation_data
        @data.is_a?(Model::CheckoutCancellation) ? @data : nil
      end

      def refund_data
        @data.is_a?(Model::Refund) ? @data : nil
      end

      def payout_data
        @data.is_a?(Model::Payout) ? @data : nil
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

      def entitlement_data
        @data.is_a?(Dto::EntitlementEventDataDto) ? @data : nil
      end

      def customer_data
        @data.is_a?(Dto::CustomerEventDataDto) ? @data : nil
      end

      def payment_data
        @data.is_a?(Dto::PaymentEventDataDto) ? @data : nil
      end

      def subscription_data
        @data.is_a?(Dto::SubscriptionEventDataDto) ? @data : nil
      end

      def invoice_data
        @data.is_a?(Dto::InvoiceEventDataDto) ? @data : nil
      end

      def settlement_data
        @data.is_a?(Dto::SettlementEventDataDto) ? @data : nil
      end

      def to_transaction
        return nil unless payment_event?
        return nil unless @data.is_a?(Dto::PaymentEventDataDto)

        Model::Transaction.new(@data.to_hash)
      end

      private

      RESOURCE_TYPES = {
        'checkout.cancellation.updated' => Model::CheckoutCancellation,
        'refund.updated' => Model::Refund,
        'withdrawal.updated' => Model::Payout
      }.freeze
      SOURCE_DTOS = {
        'customer' => Dto::CustomerEventDataDto,
        'onboarding' => Dto::OnboardingEventDataDto,
        'payment' => Dto::PaymentEventDataDto,
        'subscription' => Dto::SubscriptionEventDataDto,
        'invoice' => Dto::InvoiceEventDataDto,
        'settlement' => Dto::SettlementEventDataDto
      }.freeze
      private_constant :RESOURCE_TYPES, :SOURCE_DTOS

      def create_event_data(data, source)
        return Dto::EntitlementEventDataDto.new(data) if entitlement_source?(source)

        resource_type = RESOURCE_TYPES[@type.to_s.sub(/\.v[^.]+\z/, '')] if source == 'payment'
        return resource_type.new(data.fetch('resource', {})) if resource_type

        source_event_data(data, source)
      end

      def entitlement_source?(source)
        source == 'entitlement' || (source == 'payment' && @type == 'purchase.completed')
      end

      def source_event_data(data, source)
        dto = SOURCE_DTOS[source]
        return dto.new(data) if dto

        raise Exception::InvalidPayloadException.new("Unknown webhook source: #{source}", Exception::ExceptionCode::INVALID_PAYLOAD)
      end
    end
  end
end
