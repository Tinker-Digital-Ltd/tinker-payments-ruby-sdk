# frozen_string_literal: true

module Tinker
  module Webhook
    module Dto
      class EntitlementEventDataDto
        attr_reader :id, :transaction_id, :product_id, :external_customer_id, :entitlement_ids, :store, :period_type,
                    :amount, :currency, :purchased_at, :expiration_at, :presented_offering_id, :revoked_at,
                    :environment, :original_transaction_id

        def initialize(data)
          @id = data['id']
          @transaction_id = data['transaction_id']
          @product_id = data['product_id']
          @external_customer_id = data['external_customer_id'] || ''
          @entitlement_ids = data['entitlement_ids'] || []
          @store = data['store'] || ''
          @period_type = data['period_type'] || ''
          @amount = data['amount']
          @currency = data['currency']
          @purchased_at = data['purchased_at']
          @expiration_at = data['expiration_at']
          @presented_offering_id = data['presented_offering_id']
          @revoked_at = data['revoked_at']
          @environment = data['environment']
          @original_transaction_id = data['original_transaction_id']
        end

        def to_hash
          instance_variables.to_h { |name| [name.to_s.delete('@').to_sym, instance_variable_get(name)] }
        end
      end
    end
  end
end
