# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class SubscriptionEventDataDto
        attr_reader :id, :status, :plan_id, :account_id, :current_period_start, :current_period_end, :created_at,
                    :cancelled_at, :paused_at, :reactivated_at, :product_id, :entitlement_ids, :store, :period_type,
                    :expiration_at, :grace_period_expiration_at, :external_customer_id

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
          @product_id = data['product_id']
          @entitlement_ids = data['entitlement_ids'] || []
          @store = data['store']
          @period_type = data['period_type']
          @expiration_at = data['expiration_at']
          @grace_period_expiration_at = data['grace_period_expiration_at']
          @external_customer_id = data['external_customer_id']
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
            reactivated_at: @reactivated_at,
            product_id: @product_id,
            entitlement_ids: @entitlement_ids,
            store: @store,
            period_type: @period_type,
            expiration_at: @expiration_at,
            grace_period_expiration_at: @grace_period_expiration_at,
            external_customer_id: @external_customer_id
          }
        end
      end
    end
  end
end
