# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Webhook::WebhookHandler do
  describe '#handle' do
    it 'handles JSON string payload' do
      payload = {
        'id' => 'evt_123',
        'type' => 'payment.completed',
        'source' => 'payment',
        'timestamp' => '2024-01-01T00:00:00Z',
        'data' => {
          'id' => '123',
          'status' => 'success',
          'reference' => 'REF-123',
          'amount' => 100.0,
          'currency' => 'KES',
          'channel' => 'mpesa',
          'created_at' => '2024-01-01T00:00:00Z'
        },
        'meta' => { 'app_id' => 'app_123' },
        'security' => { 'signature' => 'sig_123' }
      }.to_json

      handler = Tinker::Webhook::WebhookHandler.new
      event = handler.handle(payload)

      expect(event).to be_a(Tinker::Webhook::WebhookEvent)
      expect(event.payment_event?).to be true
    end

    it 'handles hash payload' do
      payload = {
        'id' => 'evt_123',
        'type' => 'payment.completed',
        'source' => 'payment',
        'timestamp' => '2024-01-01T00:00:00Z',
        'data' => {
          'id' => '123',
          'status' => 'success',
          'reference' => 'REF-123',
          'amount' => 100.0,
          'currency' => 'KES',
          'channel' => 'mpesa',
          'created_at' => '2024-01-01T00:00:00Z'
        },
        'meta' => { 'app_id' => 'app_123' },
        'security' => { 'signature' => 'sig_123' }
      }

      handler = Tinker::Webhook::WebhookHandler.new
      event = handler.handle(payload)

      expect(event).to be_a(Tinker::Webhook::WebhookEvent)
    end

    it 'raises error for invalid JSON' do
      handler = Tinker::Webhook::WebhookHandler.new

      expect { handler.handle('invalid json') }.to raise_error(Tinker::Exception::InvalidPayloadException)
    end

    it 'raises error for non-hash payload' do
      handler = Tinker::Webhook::WebhookHandler.new

      expect { handler.handle('[]') }.to raise_error(Tinker::Exception::InvalidPayloadException)
    end
  end

  describe '#handle_as_transaction' do
    it 'converts payment event to transaction' do
      payload = {
        'id' => 'evt_123',
        'type' => 'payment.completed',
        'source' => 'payment',
        'timestamp' => '2024-01-01T00:00:00Z',
        'data' => {
          'id' => '123',
          'status' => 'success',
          'reference' => 'REF-123',
          'amount' => 100.0,
          'currency' => 'KES',
          'channel' => 'mpesa',
          'created_at' => '2024-01-01T00:00:00Z'
        },
        'meta' => { 'app_id' => 'app_123' },
        'security' => { 'signature' => 'sig_123' }
      }

      handler = Tinker::Webhook::WebhookHandler.new
      transaction = handler.handle_as_transaction(payload)

      expect(transaction).to be_a(Tinker::Model::Transaction)
      expect(transaction.successful?).to be true
    end

    it 'returns nil for non-payment events' do
      payload = {
        'id' => 'evt_123',
        'type' => 'subscription.created',
        'source' => 'subscription',
        'timestamp' => '2024-01-01T00:00:00Z',
        'data' => {
          'id' => '123',
          'status' => 'active'
        },
        'meta' => { 'app_id' => 'app_123' },
        'security' => { 'signature' => 'sig_123' }
      }

      handler = Tinker::Webhook::WebhookHandler.new
      transaction = handler.handle_as_transaction(payload)

      expect(transaction).to be_nil
    end
  end
end

