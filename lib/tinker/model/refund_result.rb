# frozen_string_literal: true

module Tinker
  module Model
    class RefundResult
      attr_reader :refund, :replayed, :payment

      def initialize(data)
        @refund = Refund.new(data.fetch('refund'))
        @replayed = data['replayed'] == true
        @payment = data.fetch('payment', {})
      end
    end
  end
end
