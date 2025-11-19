# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class SettlementEventDataDto
        attr_reader :id, :status, :amount, :currency, :settlement_date, :created_at, :processed_at

        def initialize(data)
          @id = data['id']
          @status = data['status']
          @amount = data['amount'].to_f
          @currency = data['currency']
          @settlement_date = data['settlement_date'] || ''
          @created_at = data['created_at'] || ''
          @processed_at = data['processed_at']
        end

        def to_hash
          {
            id: @id,
            status: @status,
            amount: @amount,
            currency: @currency,
            settlement_date: @settlement_date,
            created_at: @created_at,
            processed_at: @processed_at
          }
        end
      end
    end
  end
end

