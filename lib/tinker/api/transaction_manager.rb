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
    end
  end
end
