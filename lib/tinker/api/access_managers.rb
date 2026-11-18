# frozen_string_literal: true

module Tinker
  module Api
    class AccessManager < BaseManager
      protected

      def list_of(path)
        wrapped = request('GET', path, nil)
        wrapped['value'].is_a?(Array) ? wrapped['value'] : []
      end

      def escape(value)
        URI.encode_www_form_component(value).gsub('+', '%20')
      end
    end

    class CustomerManager < AccessManager
      def get(id)
        request('GET', customer_path(id), nil)
      end

      def get_entitlement(id, identifier)
        request('GET', "#{customer_path(id)}/entitlements/#{escape(identifier)}", nil)
      end

      def grant_promotional_entitlement(id, identifier, body = nil)
        request('POST', "#{customer_path(id)}/entitlements/#{escape(identifier)}/promotional", body)
      end

      def revoke_promotional_entitlements(id, identifier)
        request('POST', "#{customer_path(id)}/entitlements/#{escape(identifier)}/revoke_promotionals", nil)
      end

      def alias(id, body)
        request('POST', "#{customer_path(id)}/alias", body)
      end

      def transfer(id, body)
        request('POST', "#{customer_path(id)}/transfer", body)
      end

      def set_attributes(id, body)
        request('POST', "#{customer_path(id)}/attributes", body)
      end

      def get_offerings(id)
        request('GET', "#{customer_path(id)}/offerings", nil)
      end

      def create_token(id)
        request('POST', "#{customer_path(id)}/token", nil)
      end

      private

      def customer_path(id)
        "merchant/customers/#{escape(id)}"
      end
    end

    class EntitlementManager < AccessManager
      PATH = 'merchant/entitlements'

      def list
        list_of(PATH)
      end

      def create(body)
        request('POST', PATH, body)
      end

      def get(id)
        request('GET', "#{PATH}/#{escape(id)}", nil)
      end

      def update(id, body)
        request('PATCH', "#{PATH}/#{escape(id)}", body)
      end

      def delete(id)
        request('DELETE', "#{PATH}/#{escape(id)}", nil)
      end

      def attach_products(id, body)
        request('POST', "#{PATH}/#{escape(id)}/attach_products", body)
      end

      def detach_products(id, body)
        request('POST', "#{PATH}/#{escape(id)}/detach_products", body)
      end
    end

    class ProductManager < AccessManager
      PATH = 'merchant/products'

      def list
        list_of(PATH)
      end

      def create(body)
        request('POST', PATH, body)
      end

      def get(id)
        request('GET', "#{PATH}/#{escape(id)}", nil)
      end

      def update(id, body)
        request('PATCH', "#{PATH}/#{escape(id)}", body)
      end
    end

    class OfferingManager < AccessManager
      PATH = 'merchant/offerings'

      def list
        list_of(PATH)
      end

      def create(body)
        request('POST', PATH, body)
      end

      def get(id)
        request('GET', "#{PATH}/#{escape(id)}", nil)
      end

      def update(id, body)
        request('PATCH', "#{PATH}/#{escape(id)}", body)
      end

      def delete(id)
        request('DELETE', "#{PATH}/#{escape(id)}", nil)
      end
    end

    class MetricsManager < AccessManager
      def get(from: nil, to: nil)
        query = URI.encode_www_form({ from: from, to: to }.compact)
        request('GET', query.empty? ? 'merchant/metrics' : "merchant/metrics?#{query}", nil)
      end
    end

    class ExperimentManager < AccessManager
      PATH = 'merchant/experiments'

      def list
        list_of(PATH)
      end

      def create(body)
        request('POST', PATH, body)
      end

      def get(id)
        request('GET', "#{PATH}/#{escape(id)}", nil)
      end

      def stop(id)
        request('POST', "#{PATH}/#{escape(id)}/stop", nil)
      end
    end

    class IntegrationManager < AccessManager
      PATH = 'merchant/integrations'

      def list
        list_of(PATH)
      end

      def upsert(kind, body)
        request('PUT', "#{PATH}/#{escape(kind)}", body)
      end

      def delete(kind)
        request('DELETE', "#{PATH}/#{escape(kind)}", nil)
      end

      def test(kind)
        request('POST', "#{PATH}/#{escape(kind)}/test", nil)
      end
    end
  end
end
