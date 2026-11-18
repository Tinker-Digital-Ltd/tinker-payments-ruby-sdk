# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class InitiatePaymentRequestDto
        attr_reader :amount, :currency, :gateway, :merchant_reference, :return_url,
                    :customer_phone, :customer_email, :transaction_desc, :metadata, :payment_method,
                    :customer_name, :country, :product_id, :external_customer_id, :presented_offering_id

        def initialize(amount:, currency:, gateway:, merchant_reference:, return_url:,
                       customer_phone: nil, customer_email: nil, transaction_desc: nil, metadata: nil,
                       payment_method: nil, customer_name: nil, country: nil,
                       product_id: nil, external_customer_id: nil, presented_offering_id: nil)
          @amount = amount
          @currency = currency
          @gateway = gateway
          @merchant_reference = merchant_reference
          @return_url = return_url
          @customer_phone = customer_phone
          @customer_email = customer_email
          @transaction_desc = transaction_desc
          @metadata = metadata
          @payment_method = payment_method
          @customer_name = customer_name
          @country = country
          @product_id = product_id
          @external_customer_id = external_customer_id
          @presented_offering_id = presented_offering_id
        end

        def to_hash
          gateway_value = @gateway.is_a?(String) ? @gateway : @gateway.to_s

          {
            amount: @amount,
            currency: @currency,
            gateway: gateway_value,
            merchantReference: @merchant_reference,
            returnUrl: @return_url
          }.merge(optional_fields)
        end

        private

        def optional_fields
          {
            customerPhone: @customer_phone,
            customerEmail: @customer_email,
            customerName: @customer_name,
            country: @country,
            transactionDesc: @transaction_desc,
            metadata: @metadata,
            paymentMethod: @payment_method,
            productId: @product_id,
            externalCustomerId: @external_customer_id,
            presentedOfferingId: @presented_offering_id
          }.compact
        end
      end
    end
  end
end
