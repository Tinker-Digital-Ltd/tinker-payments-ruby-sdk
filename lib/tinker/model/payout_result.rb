# frozen_string_literal: true

module Tinker
  module Model
    class PayoutResult
      attr_reader :withdrawal, :replayed

      def initialize(data)
        @withdrawal = Payout.new(data.fetch('withdrawal'))
        @replayed = data['replayed'] == true
      end
    end
  end
end
