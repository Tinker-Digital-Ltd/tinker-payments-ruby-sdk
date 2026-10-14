# frozen_string_literal: true

module Tinker
  module Model
    class Transaction
      attr_reader :status, :initiation_data, :query_data, :callback_data

      def initialize(data)
        if (data['paymentReference'] || data['payment_reference']) && !data['id']
          @initiation_data = Dto::InitiationDataDto.new(data)
          @query_data = nil
          @callback_data = nil
          @status = @initiation_data.status
        elsif data['id'] && data['reference']
          @initiation_data = nil
          @query_data = Dto::QueryDataDto.new(data)
          @callback_data = Dto::CallbackDataDto.new(data)
          @status = @query_data.status
        else
          @initiation_data = nil
          @query_data = nil
          @callback_data = nil
          @status = status_from(data['status'] || 'pending')
        end
      end

      def successful?
        @status == Enum::PaymentStatus::SUCCESS
      end

      def pending?
        @status == Enum::PaymentStatus::PENDING
      end

      def cancelled?
        @status == Enum::PaymentStatus::CANCELLED
      end

      def failed?
        @status == Enum::PaymentStatus::FAILED
      end

      private

      def status_from(value)
        Enum::PaymentStatus.const_get(value.upcase)
      rescue NameError
        Enum::PaymentStatus::PENDING
      end
    end
  end
end
