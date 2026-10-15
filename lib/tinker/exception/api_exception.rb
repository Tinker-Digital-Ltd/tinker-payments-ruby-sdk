# frozen_string_literal: true

module Tinker
  module Exception
    class ApiException < StandardError
      def initialize(message, code = ExceptionCode::API_ERROR, http_status: nil, details: nil, headers: {})
        super(message)
        @code = code
        @http_status = http_status
        @details = details
        extract_metadata(details, headers)
      end

      attr_reader :code, :http_status, :error_code, :provider_code, :request_id, :retry_after, :outcome, :details

      private

      def extract_metadata(details, headers)
        error = details.is_a?(Hash) && details['error'].is_a?(Hash) ? details['error'] : {}
        normalized_headers = headers.transform_keys { |key| key.to_s.downcase }
        @error_code = error['code']
        @provider_code = error['provider_code']
        @request_id = error['request_id'] || Array(normalized_headers['x-request-id']).first
        @retry_after = Array(normalized_headers['retry-after']).first
        # Only an explicit not_applied confirms no mutation.
        @outcome = error['outcome']
      end
    end
  end
end
