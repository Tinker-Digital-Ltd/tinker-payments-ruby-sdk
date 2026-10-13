# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      # Exact integer minor-unit prices for managed recurring billing.
      class ManagedCheckout
        def initialize(external_customer_id:, email:, name:, currency:, unit_amount:, quantity:,
                       interval:, return_url:, idempotency_key:)
          @payload = {
            external_customer_id: external_customer_id, email: email, name: name, currency: currency,
            unit_amount: unit_amount, quantity: quantity, interval: interval, return_url: return_url,
            idempotency_key: idempotency_key
          }
        end

        def to_hash
          @payload.dup
        end
      end
    end
  end
end
