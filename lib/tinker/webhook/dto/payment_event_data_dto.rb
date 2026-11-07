# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class PaymentEventDataDto
        attr_reader :id, :status, :reference, :amount, :currency, :channel, :created_at, :paid_at, :country

        def initialize(data)
          @id = data['id']
          @status = Tinker::Enum::PaymentStatus.parse(data['status'])
          @reference = data['reference']
          @amount = data['amount'].to_f
          @currency = data['currency']
          @channel = data['channel']
          @created_at = data['created_at']
          @paid_at = data['paid_at']
          @country = data['country']
        end

        def to_hash
          {
            'id' => @id,
            'status' => @status.to_s,
            'reference' => @reference,
            'amount' => @amount,
            'currency' => @currency,
            'channel' => @channel,
            'created_at' => @created_at,
            'paid_at' => @paid_at
          }.merge(@country ? { 'country' => @country } : {})
        end
      end
    end
  end
end
