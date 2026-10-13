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
