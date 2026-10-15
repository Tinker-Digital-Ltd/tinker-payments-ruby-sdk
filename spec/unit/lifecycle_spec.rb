# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Merchant lifecycle operations' do
  let(:fixtures) do
    path = ENV.fetch('TINKER_LIFECYCLE_FIXTURES', File.expand_path('../fixtures/merchant-lifecycle.json', __dir__))
    JSON.parse(File.read(path))
  end
  let(:calls) { [] }
  let(:http) { instance_double(Tinker::Http::HttpClient) }
  let(:auth) { instance_double(Tinker::Auth::AuthenticationManager, token: 'token') }
  let(:config) { Tinker::Config::Configuration.new(api_public_key: 'pk', api_secret_key: 'sk', base_url: fixtures['base_url']) }
  let(:transactions) { Tinker::Api::TransactionManager.new(config: config, http_client: http, auth_manager: auth) }
  let(:payouts) { Tinker::Api::PayoutManager.new(config: config, http_client: http, auth_manager: auth) }

  def invoke(operation, fixture)
    payment = fixtures['payment_id']
    key = fixtures['key']
    case operation
    when 'refund' then transactions.refund(payment, Tinker::Model::Dto::RefundRequest.new(reason: 'requested_by_customer', amount: 100), key)
    when 'refunds' then transactions.refunds(payment)
    when 'get_refund' then transactions.get_refund(payment, fixtures['refund_id'])
    when 'payout_methods' then payouts.methods
    when 'payout_quote' then payouts.quote(payout_method_id: fixtures['payout_method_id'], amount: 100, currency: 'JPY')
    when 'request_payout' then payouts.request_payout(Tinker::Model::Dto::PayoutRequest.new(payout_method_id: fixtures['payout_method_id'], amount: 100, currency: 'JPY', expected_fee_amount: 2), key)
    when 'payouts' then payouts.list(page: 2, per_page: 10, status: 'pending_approval', currency: 'JPY')
    when 'get_payout' then payouts.get(fixtures['payout_id'])
    when 'cancel_checkout' then transactions.cancel_checkout(payment, Tinker::Model::Dto::CancellationRequest.new(reason: fixture['body']['reason']), key)
    when 'cancellations' then transactions.cancellations(payment)
    when 'get_cancellation' then transactions.get_cancellation(payment, fixtures['cancellation_id'])
    end
  end

  it 'matches the shared wire contract and preserves accepted and unknown states' do
    fixtures['cases'].each do |fixture|
      response = Tinker::Http::HttpClient::Response.new(fixture['status'], fixture['response'].to_json, {})
      allow(http).to receive(:get) do |url, headers:|
        calls << ['GET', url, headers, nil]
        response
      end
      allow(http).to receive(:post) do |url, headers:, body:|
        calls << ['POST', url, headers, JSON.parse(body)]
        response
      end
      result = invoke(fixture['operation'], fixture)
      method, url, headers, body = calls.last
      actual = URI(url)
      expected = URI("#{fixtures['base_url']}/#{fixture['path']}")
      expect(method).to eq(fixture['method'])
      expect(actual.path).to eq(expected.path)
      expect(URI.decode_www_form(actual.query || '').sort).to eq(URI.decode_www_form(expected.query || '').sort)
      expect(headers['Authorization']).to eq('Bearer token')
      expect(headers['Idempotency-Key']).to eq(fixture['headers']['Idempotency-Key'])
      expect(body).to eq(fixture['body'])
      case fixture['operation']
      when 'refund' then expect(result.refund.status).to eq('pending_review')
      when 'request_payout'
        expect(result.withdrawal.status).to eq('pending_approval')
        expect(result.withdrawal[:net_amount]).to eq(98)
      when 'cancel_checkout' then expect(result.cancellation.status).to eq('outcome_unknown')
      when 'payout_methods' then expect(result).to eq(fixture['response']['data'])
      end
    end
  end

  it 'retains a recorded rejected cancellation in structured error details without retrying' do
    details = { 'request_id' => 'cancel-1', 'status' => 'rejected' }
    payload = { success: false, error: { code: 'CHECKOUT_CANCELLATION_UNSUPPORTED', message: 'Unsupported', details: details } }
    expect(http).to receive(:post).once.and_return(Tinker::Http::HttpClient::Response.new(422, payload.to_json, {}))
    expect { transactions.cancel_checkout('payment', Tinker::Model::Dto::CancellationRequest.new(reason: 'Changed mind'), 'key') }
      .to raise_error(Tinker::Exception::ApiException) { |error| expect(error.details.dig('error', 'details')).to eq(details) }
  end

  it 'rejects blank and oversized UTF-8 keys before making HTTP calls' do
    expect(http).not_to receive(:post)
    ['', ' ', 'é' * 128, "key\r\nInjected: yes"].each do |key|
      expect { transactions.refund('payment', Tinker::Model::Dto::RefundRequest.new(reason: 'other'), key) }
        .to raise_error(Tinker::Exception::InvalidPayloadException)
    end
  end
  it 'preserves all shared structured errors and never retries a mutation' do
    fixtures['errors'].each do |fixture|
      response = Tinker::Http::HttpClient::Response.new(fixture['status'], fixture['response'].to_json, {})
      expect(http).to receive(:post).once.and_return(response)
      expect { transactions.cancel_checkout('payment', Tinker::Model::Dto::CancellationRequest.new(reason: 'Changed mind'), 'key') }
        .to raise_error(Tinker::Exception::ApiException) do |error|
          expect(error.http_status).to eq(fixture['status'])
          expect(error.error_code).to eq(fixture['response']['error']['code'])
          expect(error.details).to eq(fixture['response'])
        end
    end
  end

  it 'keeps the vendored fixture identical to the canonical contract when available' do
    canonical = File.expand_path('../../../tinker-payments-openapi/fixtures/merchant-lifecycle.json', __dir__)
    expect(fixtures).to eq(JSON.parse(File.read(canonical))) if File.file?(canonical)
    expect(fixtures['contract_version']).to eq(1)
  end
end
