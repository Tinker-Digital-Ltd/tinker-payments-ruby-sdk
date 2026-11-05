# frozen_string_literal: true

module Tinker
  module Enum
    class PaymentStatus
      PENDING = 'pending'
      SUCCESS = 'success'
      CANCELLED = 'cancelled'
      FAILED = 'failed'
      REVERSED = 'reversed'

      def self.parse(value)
        value = (value || PENDING).to_s
        value == 'completed' ? SUCCESS : value
      end
    end
  end
end
