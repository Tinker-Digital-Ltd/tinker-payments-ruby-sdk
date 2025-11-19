# frozen_string_literal: true

module Tinker
  module Exception
    class ApiException < StandardError
      def initialize(message, code = ExceptionCode::API_ERROR)
        super(message)
        @code = code
      end

      attr_reader :code
    end
  end
end

