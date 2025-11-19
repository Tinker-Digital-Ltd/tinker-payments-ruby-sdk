# frozen_string_literal: true

module Tinker
  module Webhook
    class WebhookSecurity
      attr_reader :signature, :algorithm

      def initialize(security = {})
        @signature = security['signature'] || ''
        @algorithm = security['algorithm'] || 'HMAC-SHA256'
      end
    end
  end
end
