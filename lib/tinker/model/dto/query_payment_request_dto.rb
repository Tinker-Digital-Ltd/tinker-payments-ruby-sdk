# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class QueryPaymentRequestDto
        attr_reader :payment_reference, :gateway

        def initialize(payment_reference:, gateway:)
          @payment_reference = payment_reference
          @gateway = gateway
        end

        def to_hash
          gateway_value = @gateway.is_a?(String) ? @gateway : @gateway.to_s

          {
            payment_reference: @payment_reference,
            gateway: gateway_value
          }
        end
      end
    end
  end
end
