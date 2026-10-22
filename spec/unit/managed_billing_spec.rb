# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Api::SubscriptionManager do
  let(:calls) { [] }
  let(:http) { instance_double(Tinker::Http::HttpClient) }
  let(:auth) { instance_double(Tinker::Auth::AuthenticationManager, token: 'token') }
  let(:manager) { described_class.new(config: Tinker::Config::Configuration.new(api_public_key: 'public', api_secret_key: 'secret'), http_client: http, auth_manager: auth) }
  let(:response) { Tinker::Http::HttpClient::Response.new(200, '{"success":true,"data":{"snapshot":123,"next_cursor":"in_next","has_more":true}}', {}) }

  before do
    allow(http).to receive(:post) do |url, headers:, body:|
      calls << ['POST', url.split('/v1/').last, JSON.parse(body), headers['Authorization']]
      response
    end
    allow(http).to receive(:get) do |url, headers:|
      calls << ['GET', url.split('/v1/').last, nil, headers['Authorization']]
      response
    end
  end

  it 'sends every managed operation with exact payloads and escaped IDs' do
    checkout = Tinker::Model::Dto::ManagedCheckout.new(
      external_customer_id: 'workspace', email: 'buyer@example.com', name: 'Buyer', currency: 'EUR',
      unit_amount: 15_000, quantity: 3, interval: 'year', return_url: 'https://example.com/return', idempotency_key: 'checkout-key'
    )
    expect(checkout.to_hash).to eq(
      external_customer_id: 'workspace', email: 'buyer@example.com', name: 'Buyer', currency: 'EUR',
      unit_amount: 15_000, quantity: 3, interval: 'year', return_url: 'https://example.com/return', idempotency_key: 'checkout-key'
    )
    manager.checkout(checkout)
    manager.expire_checkout('cs/a b', 'expire-key')
    manager.billing_resource('sub/a b')
    manager.change_quantity('sub/a b', 4, 'change-key')
    manager.schedule_quantity('sub/a b', 2, 'schedule-key')
    manager.clear_scheduled_quantity('sub/a b', 'clear-key')
    manager.set_cancel_at_renewal('sub/a b', false, 'resume-key')
    manager.set_trial_end('sub/a b', Time.at(1_900_000_000), 'trial-key')
    manager.end_trial('sub/a b', 'end-key')
    manager.billing_operation('key/a b')
    manager.payment_method_portal('sub/a b', 'https://example.com/return', 'portal-key')
    page = manager.billing_payment_history('sub/a b', 'in/a &b', 123)
    manager.billing_payment_history('sub/a b')
    base = 'merchant/billing/resources/sub%2Fa%20b'
    expect(calls.map { |method, path, body, _| [method, path, body] }).to eq([
                                                                               ['POST', 'merchant/billing/checkout', JSON.parse(checkout.to_hash.to_json)],
                                                                               ['POST', 'merchant/billing/checkout/cs%2Fa%20b/expire', { 'idempotency_key' => 'expire-key' }],
                                                                               ['GET', base, nil],
                                                                               ['POST', "#{base}/quantity", { 'quantity' => 4, 'idempotency_key' => 'change-key' }],
                                                                               ['POST', "#{base}/schedule", { 'quantity' => 2, 'idempotency_key' => 'schedule-key' }],
                                                                               ['POST', "#{base}/unschedule", { 'idempotency_key' => 'clear-key' }],
                                                                               ['POST', "#{base}/cancel", { 'cancel' => false, 'idempotency_key' => 'resume-key' }],
                                                                               ['POST', "#{base}/trial-end", { 'trial_end' => 1_900_000_000, 'idempotency_key' => 'trial-key' }],
                                                                               ['POST', "#{base}/end-trial", { 'idempotency_key' => 'end-key' }],
                                                                               ['GET', 'merchant/billing/operations/key%2Fa%20b', nil],
                                                                               ['POST', "#{base}/payment-method", { 'return_url' => 'https://example.com/return', 'idempotency_key' => 'portal-key' }],
                                                                               ['GET', "#{base}/payment-history?starting_after=in%2Fa+%26b&snapshot=123", nil],
                                                                               ['GET', "#{base}/payment-history", nil]
                                                                             ])
    expect(calls.map(&:last).uniq).to eq(['Bearer token'])
    expect(page).to eq('snapshot' => 123, 'next_cursor' => 'in_next', 'has_more' => true)
  end

  it 'sends trial_days only when positive' do
    args = { external_customer_id: 'workspace', email: 'buyer@example.com', name: 'Buyer', currency: 'EUR',
             unit_amount: 15_000, quantity: 3, interval: 'year', return_url: 'https://example.com/return', idempotency_key: 'checkout-key' }
    manager.checkout(Tinker::Model::Dto::ManagedCheckout.new(**args))
    manager.checkout(Tinker::Model::Dto::ManagedCheckout.new(**args, trial_days: 0))
    manager.checkout(Tinker::Model::Dto::ManagedCheckout.new(**args, trial_days: 14))
    expect(calls.map { |_, _, body, _| body.key?('trial_days') ? body['trial_days'] : nil }).to eq([nil, nil, 14])
  end

  it 'sends trial_end only when set' do
    args = { external_customer_id: 'workspace', email: 'buyer@example.com', name: 'Buyer', currency: 'EUR',
             unit_amount: 15_000, quantity: 3, interval: 'year', return_url: 'https://example.com/return', idempotency_key: 'checkout-key' }
    manager.checkout(Tinker::Model::Dto::ManagedCheckout.new(**args))
    manager.checkout(Tinker::Model::Dto::ManagedCheckout.new(**args, trial_end: Time.at(1_900_000_000)))
    expect(calls.map { |_, _, body, _| body['trial_end'] }).to eq([nil, 1_900_000_000])
  end

  [429, 200, 502].each do |status|
    context "with response status #{status}" do
      let(:response) do
        body = status == 502 ? '<html>Bad gateway</html>' : { success: false, error: { message: 'Try later', code: 'RATE_LIMITED', provider_code: 'rate_limit', request_id: 'body-id', outcome: 'not_applied' } }.to_json
        Tinker::Http::HttpClient::Response.new(status, body, 'x-request-id' => ['header-id'], 'rEtRy-AfTeR' => ['30'])
      end

      it 'retains recovery information without inferring an unapplied outcome' do
        expect { manager.list_plans }.to raise_error(Tinker::Exception::ApiException) do |error|
          expect(error.http_status).to eq(status)
          expect(error.retry_after).to eq('30')
          expect(error.request_id).to eq(status == 502 ? 'header-id' : 'body-id')
          expect(error.error_code).to eq(status == 502 ? nil : 'RATE_LIMITED')
          expect(error.provider_code).to eq(status == 502 ? nil : 'rate_limit')
          expect(error.outcome).to eq(status == 502 ? nil : 'not_applied')
        end
      end
    end
  end

  it 'keeps legacy API exception arguments' do
    error = Tinker::Exception::ApiException.new('legacy', 123)
    expect(error.code).to eq(123)
    expect(error.message).to eq('legacy')
  end
end
