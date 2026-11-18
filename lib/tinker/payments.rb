# frozen_string_literal: true

require_relative 'version'
require_relative 'config/configuration'
require_relative 'config/endpoints'
require_relative 'http/http_client'
require_relative 'auth/authentication_manager'
require_relative 'api/base_manager'
require_relative 'api/transaction_manager'
require_relative 'api/subscription_manager'
require_relative 'api/access_managers'
require_relative 'api/payout_manager'
require_relative 'webhook/webhook_handler'

module Tinker
  class Payments
    def initialize(api_public_key:, api_secret_key:, http_client: nil, base_url: nil)
      @config = Config::Configuration.new(api_public_key: api_public_key, api_secret_key: api_secret_key,
                                          base_url: base_url)
      @http_client = http_client || Http::HttpClient.new
      @auth_manager = Auth::AuthenticationManager.new(config: @config, http_client: @http_client)
    end

    def transactions
      @transactions ||= Api::TransactionManager.new(
        config: @config,
        http_client: @http_client,
        auth_manager: @auth_manager
      )
    end

    def subscriptions
      @subscriptions ||= Api::SubscriptionManager.new(
        config: @config,
        http_client: @http_client,
        auth_manager: @auth_manager
      )
    end

    def payouts
      @payouts ||= Api::PayoutManager.new(config: @config, http_client: @http_client, auth_manager: @auth_manager)
    end

    def customers
      @customers ||= Api::CustomerManager.new(config: @config, http_client: @http_client, auth_manager: @auth_manager)
    end

    def entitlements
      @entitlements ||= Api::EntitlementManager.new(
        config: @config,
        http_client: @http_client,
        auth_manager: @auth_manager
      )
    end

    def products
      @products ||= Api::ProductManager.new(config: @config, http_client: @http_client, auth_manager: @auth_manager)
    end

    def offerings
      @offerings ||= Api::OfferingManager.new(config: @config, http_client: @http_client, auth_manager: @auth_manager)
    end

    def metrics
      @metrics ||= Api::MetricsManager.new(config: @config, http_client: @http_client, auth_manager: @auth_manager)
    end

    def experiments
      @experiments ||= Api::ExperimentManager.new(
        config: @config,
        http_client: @http_client,
        auth_manager: @auth_manager
      )
    end

    def integrations
      @integrations ||= Api::IntegrationManager.new(
        config: @config,
        http_client: @http_client,
        auth_manager: @auth_manager
      )
    end

    def webhooks
      @webhooks ||= Webhook::WebhookHandler.new
    end

    def last_auth_meta
      @auth_manager.last_meta
    end
  end
end
