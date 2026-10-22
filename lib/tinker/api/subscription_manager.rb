# frozen_string_literal: true

require 'cgi'

module Tinker
  module Api
    class SubscriptionManager < BaseManager
      def create_plan(request)
        payload = request.to_hash
        request('POST', Config::Endpoints::SUBSCRIPTION_PLANS_PATH, payload)
      end

      def list_plans
        wrapped = request('GET', Config::Endpoints::SUBSCRIPTION_PLANS_PATH, nil)
        wrapped['value'].is_a?(Array) ? wrapped['value'] : []
      end

      def create(request)
        payload = request.to_hash
        request('POST', Config::Endpoints::SUBSCRIPTION_BASE_PATH, payload)
      end

      def list(plan_id: nil, external_customer_id: nil)
        endpoint = Config::Endpoints::SUBSCRIPTION_BASE_PATH
        params = []
        params << "plan_id=#{CGI.escape(plan_id)}" if plan_id && !plan_id.strip.empty?
        if external_customer_id && !external_customer_id.strip.empty?
          params << "external_customer_id=#{CGI.escape(external_customer_id)}"
        end
        endpoint += "?#{params.join('&')}" unless params.empty?

        wrapped = request('GET', endpoint, nil)
        wrapped['value'].is_a?(Array) ? wrapped['value'] : []
      end

      def cancel(subscription_id)
        request('POST', "#{Config::Endpoints::SUBSCRIPTION_BASE_PATH}/#{subscription_id}/cancel", nil)
      end

      def checkout(request)
        request('POST', 'merchant/billing/checkout', request.to_hash)
      end

      def billing_resource(id)
        request('GET', billing_resource_path(id))
      end

      def change_quantity(id, quantity, key)
        request('POST', "#{billing_resource_path(id)}/quantity", quantity: quantity, idempotency_key: key)
      end

      def schedule_quantity(id, quantity, key)
        request('POST', "#{billing_resource_path(id)}/schedule", quantity: quantity, idempotency_key: key)
      end

      def clear_scheduled_quantity(id, key)
        request('POST', "#{billing_resource_path(id)}/unschedule", idempotency_key: key)
      end

      def set_cancel_at_renewal(id, cancel, key)
        request('POST', "#{billing_resource_path(id)}/cancel", cancel: cancel, idempotency_key: key)
      end

      def set_trial_end(id, end_time, key)
        request('POST', "#{billing_resource_path(id)}/trial-end", trial_end: end_time.to_i, idempotency_key: key)
      end

      def end_trial(id, key)
        request('POST', "#{billing_resource_path(id)}/end-trial", idempotency_key: key)
      end

      def billing_operation(key)
        request('GET', "merchant/billing/operations/#{escape_path(key)}")
      end

      def payment_method_portal(id, return_url, key)
        request('POST', "#{billing_resource_path(id)}/payment-method", return_url: return_url, idempotency_key: key)
      end

      def billing_payment_history(id, cursor = '', snapshot = 0)
        params = {}
        params['starting_after'] = cursor unless cursor.empty?
        params['snapshot'] = snapshot if snapshot.positive?
        endpoint = "#{billing_resource_path(id)}/payment-history"
        endpoint += "?#{URI.encode_www_form(params)}" unless params.empty?
        request('GET', endpoint)
      end

      private

      def billing_resource_path(id)
        "merchant/billing/resources/#{escape_path(id)}"
      end

      def escape_path(value)
        URI.encode_www_form_component(value).gsub('+', '%20')
      end
    end
  end
end
