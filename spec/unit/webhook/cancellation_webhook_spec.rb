# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Webhook::WebhookHandler do
  it 'verifies the Go-signed cancellation without creating a payment transaction' do
    payload = File.read(File.expand_path('../../fixtures/checkout-cancellation-webhook.json', __dir__))
    handler = described_class.new
    event = handler.handle(payload)
    expect(event.cancellation_data.status).to eq('outcome_unknown')
    expect(event.payment_data).to be_nil
    expect(event.to_transaction).to be_nil
    expect(handler.verify_signature(event, 'webhook-secret')).to be true
    expect(handler.verify_signature(payload, 'webhook-secret')).to be true
    expect(handler.verify_signature(payload, 'wrong-secret')).to be false
    expect(handler.verify_signature(payload.sub('outcome_unknown', 'cancelled'), 'webhook-secret')).to be false
  end
end
