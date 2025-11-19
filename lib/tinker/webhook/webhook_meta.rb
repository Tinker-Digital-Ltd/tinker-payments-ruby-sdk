# frozen_string_literal: true

module Tinker
  module Webhook
    class WebhookMeta
      attr_reader :version, :app_id, :gateway

      def initialize(meta = {})
        @version = meta['version'] || '1.0'
        @app_id = meta['app_id'] || ''
        @gateway = meta['gateway']
      end
    end
  end
end
