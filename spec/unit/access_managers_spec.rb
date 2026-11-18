# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'customer access managers' do
  let(:calls) { [] }
  let(:http) { instance_double(Tinker::Http::HttpClient) }
  let(:auth) { instance_double(Tinker::Auth::AuthenticationManager, token: 'token') }
  let(:config) { Tinker::Config::Configuration.new(api_public_key: 'public', api_secret_key: 'secret') }
  let(:response) { Tinker::Http::HttpClient::Response.new(200, '{"success":true,"data":{"ok":true}}', {}) }
  let(:args) { { config: config, http_client: http, auth_manager: auth } }

  before do
    allow(http).to receive(:get) do |url, headers:|
      calls << ['GET', url.split('/v1/').last, nil, headers['Authorization']]
      response
    end
    %i[post put patch delete].each do |verb|
      allow(http).to receive(verb) do |url, headers:, body: nil|
        calls << [verb.to_s.upcase, url.split('/v1/').last, body && JSON.parse(body), headers['Authorization']]
        response
      end
    end
  end

  it 'calls every customer route' do
    m = Tinker::Api::CustomerManager.new(**args)
    m.get_customer('u/1')
    m.get_entitlement('u1', 'pro')
    m.grant_promotional_entitlement('u1', 'pro', duration: 'P7D')
    m.revoke_promotional_entitlements('u1', 'pro')
    m.alias('u1', 'a')
    m.transfer('u1', 'u2')
    m.set_attributes('u1', { plan: 'x' })
    m.get_offerings('u1')
    m.create_token('u1')
    m.create_token('u1', expires_in: 300)
    expect(calls.map { |c| c.first(3) }).to eq(
      [
        ['GET', 'merchant/customers/u%2F1', nil],
        ['GET', 'merchant/customers/u1/entitlements/pro', nil],
        ['POST', 'merchant/customers/u1/entitlements/pro/promotional', { 'duration' => 'P7D' }],
        ['POST', 'merchant/customers/u1/entitlements/pro/revoke_promotionals', nil],
        ['POST', 'merchant/customers/u1/alias', { 'alias' => 'a' }],
        ['POST', 'merchant/customers/u1/transfer', { 'to' => 'u2' }],
        ['POST', 'merchant/customers/u1/attributes', { 'attributes' => { 'plan' => 'x' } }],
        ['GET', 'merchant/customers/u1/offerings', nil],
        ['POST', 'merchant/customers/u1/token', nil],
        ['POST', 'merchant/customers/u1/token', { 'expires_in' => 300 }]
      ]
    )
    expect(calls.map(&:last).uniq).to eq(['Bearer token'])
  end

  it 'calls catalogue, experiment, integration, metrics and renewal prompt routes' do
    e = Tinker::Api::EntitlementManager.new(**args)
    p = Tinker::Api::ProductManager.new(**args)
    o = Tinker::Api::OfferingManager.new(**args)
    x = Tinker::Api::ExperimentManager.new(**args)
    i = Tinker::Api::IntegrationManager.new(**args)
    body = { 'k' => 'v' }
    [e.list, e.create(body), e.get('e1'), e.update('e1', 'n'), e.delete('e1'),
     e.attach_products('e1', ['p']), e.detach_products('e1', ['p']),
     p.list, p.create(body), p.get('p1'), p.update('p1', body),
     o.list, o.create(body), o.get('o1'), o.update('o1', body), o.delete('o1'),
     x.list, x.create(body), x.get('x1'), x.stop('x1'),
     i.list, i.put('slack', body), i.delete('slack'), i.test('slack')]
    metrics = Tinker::Api::MetricsManager.new(**args)
    metrics.get
    metrics.get(from: '2026-01-01', to: '2026-01-31')
    subs = Tinker::Api::SubscriptionManager.new(**args)
    subs.list_renewal_prompts
    subs.list_renewal_prompts(subscription_id: 'sub_1')
    subs.send_renewal_prompt('sub_1')
    expect(calls.map { |c| c.first(3) }).to eq(
      [
        ['GET', 'merchant/entitlements', nil],
        ['POST', 'merchant/entitlements', body],
        ['GET', 'merchant/entitlements/e1', nil],
        ['PATCH', 'merchant/entitlements/e1', { 'display_name' => 'n' }],
        ['DELETE', 'merchant/entitlements/e1', nil],
        ['POST', 'merchant/entitlements/e1/attach_products', { 'product_ids' => ['p'] }],
        ['POST', 'merchant/entitlements/e1/detach_products', { 'product_ids' => ['p'] }],
        ['GET', 'merchant/products', nil],
        ['POST', 'merchant/products', body],
        ['GET', 'merchant/products/p1', nil],
        ['PATCH', 'merchant/products/p1', body],
        ['GET', 'merchant/offerings', nil],
        ['POST', 'merchant/offerings', body],
        ['GET', 'merchant/offerings/o1', nil],
        ['PATCH', 'merchant/offerings/o1', body],
        ['DELETE', 'merchant/offerings/o1', nil],
        ['GET', 'merchant/experiments', nil],
        ['POST', 'merchant/experiments', body],
        ['GET', 'merchant/experiments/x1', nil],
        ['POST', 'merchant/experiments/x1/stop', nil],
        ['GET', 'merchant/integrations', nil],
        ['PUT', 'merchant/integrations/slack', body],
        ['DELETE', 'merchant/integrations/slack', nil],
        ['POST', 'merchant/integrations/slack/test', nil],
        ['GET', 'merchant/metrics', nil],
        ['GET', 'merchant/metrics?from=2026-01-01&to=2026-01-31', nil],
        ['GET', 'merchant/subscriptions/renewal_prompts', nil],
        ['GET', 'merchant/subscriptions/renewal_prompts?subscription_id=sub_1', nil],
        ['POST', 'merchant/subscriptions/sub_1/renewal_prompt', nil]
      ]
    )
  end

  it 'exposes the managers on the client' do
    client = Tinker::Payments.new(api_public_key: 'public', api_secret_key: 'secret', http_client: http)
    expect(client.customers).to be_a(Tinker::Api::CustomerManager)
    expect(client.integrations).to be_a(Tinker::Api::IntegrationManager)
  end

  it 'sends access fields on payment initiation' do
    dto = Tinker::Model::Dto::InitiatePaymentRequestDto.new(
      amount: 1, currency: 'KES', gateway: 'mpesa', merchant_reference: 'r', return_url: 'https://x.test',
      product_id: 'p1', external_customer_id: 'u1', presented_offering_id: 'default'
    )
    expect(dto.to_hash).to include(productId: 'p1', externalCustomerId: 'u1', presentedOfferingId: 'default')
  end

  it 'parses access webhook events' do
    event = lambda do |type, source, data|
      Tinker::Webhook::WebhookEvent.new('id' => 'e', 'type' => type, 'source' => source, 'data' => data)
    end
    purchase = event.call('purchase.completed', 'payment',
                          'external_customer_id' => 'u1', 'entitlement_ids' => ['pro'], 'product_id' => 'p1')
    expect(purchase.entitlement_data.product_id).to eq('p1')
    expect(purchase.payment_data).to be_nil
    expect(event.call('entitlement.granted', 'entitlement', 'id' => 'g').entitlement_data.id).to eq('g')
    moved = event.call('customer.transferred', 'customer', 'transferred_from' => ['a'], 'transferred_to' => ['b'])
    expect(moved.customer_data.transferred_to).to eq(['b'])
    sub = event.call('subscription.billing_issue', 'subscription',
                     'subscription_id' => 's', 'external_customer_id' => 'u1', 'entitlement_ids' => ['pro'], 'grace_period_expiration_at' => 'g')
    expect(sub.subscription_data.grace_period_expiration_at).to eq('g')
    expect(sub.subscription_data.entitlement_ids).to eq(['pro'])
    expect(sub.subscription_data.external_customer_id).to eq('u1')
  end
end
