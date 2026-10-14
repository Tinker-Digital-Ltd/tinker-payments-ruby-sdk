# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Webhook::WebhookHandler do
  it 'recognizes and verifies the Go setup test without creating a payment' do
    payload = File.read(File.expand_path('../../fixtures/setup-webhook.json', __dir__))
    handler = described_class.new
    event = handler.handle(payload)
    expect(event.onboarding_event?).to be true
    expect(event.setup_test?).to be true
    expect(event.onboarding_data.message).to include('webhook verification')
    expect(event.payment_data).to be_nil
    expect(handler.handle_as_transaction(payload)).to be_nil
    expect(handler.verify_signature(event, 'webhook-secret')).to be true
    expect(handler.verify_signature(payload, 'webhook-secret')).to be true
    expect(handler.verify_signature(payload, 'wrong-secret')).to be false
    expect(handler.verify_signature(payload, '')).to be false
    [['verification', 'forged'], ['HMAC-SHA256', 'none'], ['sha256=', 'invalid=']].each do |before, after|
      expect(handler.verify_signature(payload.sub(before, after), 'webhook-secret')).to be false
    end
    expect(handler.handle(payload.sub('setup.webhook_test', 'onboarding.future')).setup_test?).to be false
    expect { handler.handle(payload.sub('"source":"onboarding"', '"source":"unknown"')) }
      .to raise_error(Tinker::Exception::InvalidPayloadException)
  end
end
