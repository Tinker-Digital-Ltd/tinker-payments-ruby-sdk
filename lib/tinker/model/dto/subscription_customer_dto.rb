# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class SubscriptionCustomerDto
        def initialize(external_customer_id:, name:, email: nil, phone: nil, metadata: nil)
          @external_customer_id = external_customer_id
          @name = name
          @email = email
          @phone = phone
          @metadata = metadata
        end

        def to_hash
          payload = {
            external_customer_id: @external_customer_id,
            name: @name
          }
          payload[:email] = @email if @email
          payload[:phone] = @phone if @phone
          payload[:metadata] = @metadata if @metadata
          payload
        end
      end
    end
  end
end
