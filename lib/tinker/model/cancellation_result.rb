# frozen_string_literal: true

module Tinker
  module Model
    class CancellationResult
      attr_reader :cancellation, :replayed

      def initialize(data)
        @cancellation = CheckoutCancellation.new(data.fetch('cancellation'))
        @replayed = data['replayed'] == true
      end
    end
  end
end
