# frozen_string_literal: true

module Tinker
  module Api
    # Payouts are withdrawals to the merchant's own verified account.
    class PayoutManager < BaseManager
      def methods
        request('GET', 'merchant/payout-methods').fetch('value', [])
      end

      def quote(payout_method_id:, amount:, currency: nil)
        params = { payout_method_id: payout_method_id, amount: amount, currency: currency }.compact
        request('GET', "merchant/payouts/quote?#{URI.encode_www_form(params)}")
      end

      def request_payout(payload, key)
        Model::PayoutResult.new(request('POST', 'merchant/payouts', payload.to_hash, operation_headers(key)))
      end

      def list(page: nil, per_page: nil, status: nil, currency: nil)
        params = { page: page, per_page: per_page, status: status, currency: currency }.compact
        query = params.empty? ? '' : "?#{URI.encode_www_form(params)}"
        request('GET', "merchant/payouts#{query}")
      end

      def get(id)
        Model::Payout.new(request('GET', "merchant/payouts/#{resource_id(id)}"))
      end
    end
  end
end
