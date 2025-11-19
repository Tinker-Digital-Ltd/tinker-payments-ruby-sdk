# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class InitiationDataDto
        attr_reader :payment_reference, :status, :authorization_url

        def initialize(data)
          @payment_reference = data['payment_reference']
          status_value = data['status'] || 'pending'
          @status = begin
            Tinker::Enum::PaymentStatus.const_get(status_value.upcase)
          rescue NameError
            Tinker::Enum::PaymentStatus::PENDING
          end
          @authorization_url = data['authorization_url']
        end

        def to_hash
          {
            payment_reference: @payment_reference,
            status: @status,
            authorization_url: @authorization_url
          }
        end
      end
    end
  end
end

