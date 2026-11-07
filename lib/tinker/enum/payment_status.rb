# frozen_string_literal: true

module Tinker
  module Enum
    class PaymentStatus
      PENDING = 'pending'
      AUTHORISED = 'authorised'
      SUCCESS = 'success'
      CANCELLED = 'cancelled'
      FAILED = 'failed'
      BLOCKED = 'blocked'
      REFUNDED = 'refunded'
      PARTIALLY_REFUNDED = 'partially_refunded'
      EXPIRED = 'expired'
      REVERSED = 'reversed'

      def self.parse(value)
        value = (value || PENDING).to_s
        value == 'completed' ? SUCCESS : value
      end
    end
  end
end
