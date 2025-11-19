# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class InvoiceEventDataDto
        attr_reader :id, :status, :invoice_number, :amount, :currency, :subscription_id, :created_at, :paid_at

        def initialize(data)
          @id = data['id']
          @status = data['status']
          @invoice_number = data['invoice_number'] || ''
          @amount = data['amount'].to_f
          @currency = data['currency']
          @subscription_id = data['subscription_id'] || ''
          @created_at = data['created_at'] || ''
          @paid_at = data['paid_at']
        end

        def to_hash
          {
            id: @id,
            status: @status,
            invoice_number: @invoice_number,
            amount: @amount,
            currency: @currency,
            subscription_id: @subscription_id,
            created_at: @created_at,
            paid_at: @paid_at
          }
        end
      end
    end
  end
end
