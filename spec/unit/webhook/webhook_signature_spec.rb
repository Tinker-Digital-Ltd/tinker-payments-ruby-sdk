# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Webhook::WebhookHandler do
  it 'verifies server signatures and rejects wrong secrets, changed amounts and short signatures' do
    unsigned = '{"id":"event-1","type":"payment.completed","source":"payment","timestamp":"2026-09-06T00:00:00Z","data":{"amount":15,"currency":"EUR"},"meta":{"app_id":"app-1"}}'
    signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', 'test-secret', unsigned)}"
    signed = unsigned[0...-1] + ",\"security\":{\"signature\":\"#{signature}\"}}"
    handler = described_class.new
    expect(handler.verify_signature(signed, 'test-secret')).to be true
    expect(handler.verify_signature(signed, 'wrong-secret')).to be false
    expect(handler.verify_signature(signed, '')).to be false
    expect(handler.verify_signature(signed.sub('15', '150'), 'test-secret')).to be false
    expect(handler.verify_signature(signed.sub(signature, 'sha256=1'), 'test-secret')).to be false
  end
end
