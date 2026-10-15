# frozen_string_literal: true

module Tinker
  module Api
    class TransactionManager < BaseManager
      def initiate(request)
        payload = request.to_hash
        response = request('POST', Config::Endpoints::PAYMENT_INITIATE_PATH, payload)

        Model::Transaction.new(response)
      end

      def query(request)
        payload = request.to_hash
        response = request('POST', Config::Endpoints::PAYMENT_QUERY_PATH, payload)

        Model::Transaction.new(response)
      end

      def refund(payment_id, payload, key)
        result = request('POST', "#{payment_path(payment_id)}/refund", payload.to_hash, operation_headers(key))
        Model::RefundResult.new(result)
      end

      def refunds(payment_id)
        request('GET', "#{payment_path(payment_id)}/refunds")
      end

      def get_refund(payment_id, refund_id)
        Model::Refund.new(request('GET', "#{payment_path(payment_id)}/refunds/#{resource_id(refund_id)}"))
      end

      def cancel_checkout(payment_id, payload, key)
        result = request('POST', "#{payment_path(payment_id)}/cancellations", payload.to_hash, operation_headers(key))
        Model::CancellationResult.new(result)
      end

      def cancellations(payment_id)
        request('GET', "#{payment_path(payment_id)}/cancellations")
      end

      def get_cancellation(payment_id, request_id)
        endpoint = "#{payment_path(payment_id)}/cancellations/#{resource_id(request_id)}"
        Model::CheckoutCancellation.new(request('GET', endpoint))
      end
    end
  end
end
