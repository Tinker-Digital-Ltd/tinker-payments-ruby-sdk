# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class InitiatePaymentRequestDto
        attr_reader :amount, :currency, :gateway, :merchant_reference, :return_url,
                    :customer_phone, :customer_email, :transaction_desc, :metadata

        def initialize(amount:, currency:, gateway:, merchant_reference:, return_url:,
                       customer_phone: nil, customer_email: nil, transaction_desc: nil, metadata: nil)
          @amount = amount
          @currency = currency
          @gateway = gateway
          @merchant_reference = merchant_reference
          @return_url = return_url
          @customer_phone = customer_phone
          @customer_email = customer_email
          @transaction_desc = transaction_desc
          @metadata = metadata
        end

        def to_hash
          gateway_value = @gateway.is_a?(String) ? @gateway : @gateway.to_s

          payload = {
            amount: @amount,
            currency: @currency,
            gateway: gateway_value,
            merchantReference: @merchant_reference,
            returnUrl: @return_url
          }

          payload[:customerPhone] = @customer_phone if @customer_phone
          payload[:customerEmail] = @customer_email if @customer_email
          payload[:transactionDesc] = @transaction_desc if @transaction_desc
          payload[:metadata] = @metadata if @metadata

          payload
        end
      end
    end
  end
end
