# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class RefundRequest
        def initialize(reason:, amount: nil, note: nil)
          @payload = { reason: reason, amount: amount, note: note }.compact
        end

        def to_hash
          @payload.dup
        end
      end
    end
  end
end
