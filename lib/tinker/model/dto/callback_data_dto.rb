# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class CallbackDataDto
        attr_reader :id, :status, :reference, :amount, :currency, :paid_at, :created_at, :channel, :country

        def initialize(data)
          @id = data['id']
          @status = Tinker::Enum::PaymentStatus.parse(data['status'])
          @reference = data['reference']
          @amount = data['amount'].to_f
          @currency = data['currency']
          @paid_at = data['paid_at']
          @created_at = data['created_at']
          @channel = data['channel']
          @country = data['country']
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
          }.merge(@country ? { country: @country } : {})
        end
      end
    end
  end
end
