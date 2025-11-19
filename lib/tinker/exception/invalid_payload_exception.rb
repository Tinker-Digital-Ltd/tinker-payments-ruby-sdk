# frozen_string_literal: true

module Tinker
  module Exception
    class InvalidPayloadException < StandardError
      def initialize(message, code = ExceptionCode::INVALID_PAYLOAD, previous = nil)
        super(message)
        @code = code
        set_backtrace(previous.backtrace) if previous
      end

      attr_reader :code
    end
  end
end

