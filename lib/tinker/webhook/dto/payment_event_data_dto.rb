# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class PaymentEventDataDto
        attr_reader :id, :status, :reference, :amount, :currency, :channel, :created_at, :paid_at

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
          @channel = data['channel']
          @created_at = data['created_at']
          @paid_at = data['paid_at']
        end

        def to_hash
          {
            'id' => @id,
            'status' => @status.is_a?(String) ? @status : @status.to_s,
            'reference' => @reference,
            'amount' => @amount,
            'currency' => @currency,
            'channel' => @channel,
            'created_at' => @created_at,
            'paid_at' => @paid_at
          }
        end
      end
    end
  end
end

