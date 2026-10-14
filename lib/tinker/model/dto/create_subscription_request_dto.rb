# frozen_string_literal: true

module Tinker
  module Model
    module Dto
      class CreateSubscriptionRequestDto
        def initialize(plan_id:, gateway:, customer:, payment_method_id: nil, billing_period: nil)
          @plan_id = plan_id
          @gateway = gateway
          @customer = customer
          @payment_method_id = payment_method_id
          @billing_period = billing_period
        end

        def to_hash
          payload = {
            plan_id: @plan_id,
            gateway: @gateway,
            customer: @customer.to_hash
          }
          payload[:payment_method_id] = @payment_method_id if @payment_method_id
          payload[:billing_period] = @billing_period if @billing_period
          payload
        end
      end
    end
  end
end
