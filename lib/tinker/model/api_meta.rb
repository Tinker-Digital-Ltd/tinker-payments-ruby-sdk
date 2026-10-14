# frozen_string_literal: true

module Tinker
  module Model
    class ApiMeta
      attr_reader :request_id, :timestamp, :environment

      def initialize(meta = {})
        @request_id = meta['request_id']
        @timestamp = meta['timestamp']
        @environment = meta['environment']
      end

      def to_hash
        {
          request_id: @request_id,
          timestamp: @timestamp,
          environment: @environment
        }
      end
    end
  end
end
