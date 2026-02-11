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
        params << "external_customer_id=#{CGI.escape(external_customer_id)}" if external_customer_id && !external_customer_id.strip.empty?
        endpoint += "?#{params.join('&')}" unless params.empty?

        wrapped = request('GET', endpoint, nil)
        wrapped['value'].is_a?(Array) ? wrapped['value'] : []
      end

      def cancel(subscription_id)
        request('POST', "#{Config::Endpoints::SUBSCRIPTION_BASE_PATH}/#{subscription_id}/cancel", nil)
      end
    end
  end
end
