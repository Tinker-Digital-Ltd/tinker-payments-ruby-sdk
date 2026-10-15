# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class PayoutRequest
        def initialize(payout_method_id:, amount:, currency:, expected_fee_amount:)
          @payload = { payout_method_id: payout_method_id, amount: amount, currency: currency,
                       expected_fee_amount: expected_fee_amount }
        end

        def to_hash
          @payload.dup
        end
      end
    end
  end
end
