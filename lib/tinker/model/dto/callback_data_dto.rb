# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class CallbackDataDto
        attr_reader :id, :status, :reference, :amount, :currency, :paid_at, :created_at, :channel

        def initialize(data)
          @id = data['id']
          status_value = data['status'] || 'pending'
          @status = begin
            Tinker::Enum::PaymentStatus.const_get(status_value.upcase)
          rescue NameError
            Tinker::Enum::PaymentStatus::PENDING
          end
          @reference = data['reference']
          @amount = data['amount'].to_f
          @currency = data['currency']
          @paid_at = data['paid_at']
          @created_at = data['created_at']
          @channel = data['channel']
        end

        def to_hash
          {
            id: @id,
            status: @status,
            reference: @reference,
            amount: @amount,
            currency: @currency,
            paid_at: @paid_at,
            created_at: @created_at,
            channel: @channel
          }
        end
      end
    end
  end
end

