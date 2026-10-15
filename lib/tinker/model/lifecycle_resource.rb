# frozen_string_literal: true

module Tinker
  module Model
    # Keep provider-independent status and all additive response fields.
    class LifecycleResource
      def initialize(data)
        @data = data.dup
      end

      def id
        @data['id']
      end

      def status
        @data['status']
      end

      def [](key)
        @data[key.to_s]
      end

      def to_hash
        @data.dup
      end
    end
  end
end
