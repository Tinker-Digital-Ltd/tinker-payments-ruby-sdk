# frozen_string_literal: true

module Tinker
  module Exception
    class FeatureNotSupportedException < ApiException
      CODE = 'FEATURE_NOT_SUPPORTED'

      def gateway
        error_details['gateway']
      end

      def feature
        error_details['feature']
      end

      def alternatives
        Array(error_details['alternatives'])
      end

      private

      def error_details
        error = @details.is_a?(Hash) ? @details['error'] : nil
        error.is_a?(Hash) && error['details'].is_a?(Hash) ? error['details'] : {}
      end
    end
  end
end
