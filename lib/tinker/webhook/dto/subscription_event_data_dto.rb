# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class SubscriptionEventDataDto
        attr_reader :id, :status, :plan_id, :account_id, :current_period_start, :current_period_end, :created_at,
                    :cancelled_at, :paused_at, :reactivated_at

        def initialize(data)
          @id = data['subscription_id'] || data['id']
          @status = data['status'] || ''
          @plan_id = data['plan_id'] || ''
          @account_id = data['account_id'] || data['customer_id'] || ''
          @current_period_start = data['current_period_start']
          @current_period_end = data['current_period_end']
          @created_at = data['created_at'] || @current_period_start || ''
          @cancelled_at = data['cancelled_at']
          @paused_at = data['paused_at']
          @reactivated_at = data['reactivated_at']
        end

        def to_hash
          {
            id: @id,
            subscription_id: @id,
            status: @status,
            plan_id: @plan_id,
            account_id: @account_id,
            current_period_start: @current_period_start,
            current_period_end: @current_period_end,
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
