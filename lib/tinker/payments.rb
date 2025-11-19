# frozen_string_literal: true

require_relative 'version'
require_relative 'config/configuration'
require_relative 'config/endpoints'
require_relative 'http/http_client'
require_relative 'auth/authentication_manager'
require_relative 'api/base_manager'
require_relative 'api/transaction_manager'
require_relative 'webhook/webhook_handler'

module Tinker
  class Payments
    def initialize(api_public_key:, api_secret_key:, http_client: nil)
      @config = Config::Configuration.new(api_public_key: api_public_key, api_secret_key: api_secret_key)
      @http_client = http_client || Http::HttpClient.new
      @auth_manager = Auth::AuthenticationManager.new(config: @config, http_client: @http_client)
      @transactions_manager = nil
      @webhook_handler = nil
    end

    def transactions
      @transactions ||= Api::TransactionManager.new(
        config: @config,
        http_client: @http_client,
        auth_manager: @auth_manager
      )
    end

    def webhooks
      @webhooks ||= Webhook::WebhookHandler.new
    end
  end
end
