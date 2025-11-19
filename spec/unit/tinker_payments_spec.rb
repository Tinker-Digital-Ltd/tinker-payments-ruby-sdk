# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Payments do
  describe '#initialize' do
    it 'initializes with API keys' do
      tinker = Tinker::Payments.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456'
      )

      expect(tinker).to be_a(Tinker::Payments)
    end

    it 'accepts custom HTTP client' do
      custom_client = double('HttpClient')
      tinker = Tinker::Payments.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456',
        http_client: custom_client
      )

      expect(tinker).to be_a(Tinker::Payments)
    end
  end

  describe '#transactions' do
    it 'returns TransactionManager instance' do
      tinker = Tinker::Payments.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456'
      )

      expect(tinker.transactions).to be_a(Tinker::Api::TransactionManager)
    end

    it 'returns same instance on multiple calls' do
      tinker = Tinker::Payments.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456'
      )

      transactions1 = tinker.transactions
      transactions2 = tinker.transactions

      expect(transactions1).to be(transactions2)
    end
  end

  describe '#webhooks' do
    it 'returns WebhookHandler instance' do
      tinker = Tinker::Payments.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456'
      )

      expect(tinker.webhooks).to be_a(Tinker::Webhook::WebhookHandler)
    end

    it 'returns same instance on multiple calls' do
      tinker = Tinker::Payments.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456'
      )

      webhooks1 = tinker.webhooks
      webhooks2 = tinker.webhooks

      expect(webhooks1).to be(webhooks2)
    end
  end
end
