# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class SubscriptionEventDataDto
        attr_reader :id, :status, :plan_id, :customer_id, :created_at, :cancelled_at, :paused_at, :reactivated_at

        def initialize(data)
          @id = data['id']
          @status = data['status']
          @plan_id = data['plan_id'] || ''
          @customer_id = data['customer_id'] || ''
          @created_at = data['created_at'] || ''
          @cancelled_at = data['cancelled_at']
          @paused_at = data['paused_at']
          @reactivated_at = data['reactivated_at']
        end

        def to_hash
          {
            id: @id,
            status: @status,
            plan_id: @plan_id,
            customer_id: @customer_id,
            created_at: @created_at,
            cancelled_at: @cancelled_at,
            paused_at: @paused_at,
            reactivated_at: @reactivated_at
          }
        end
      end
    end
  end
end
