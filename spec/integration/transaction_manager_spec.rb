# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'TransactionManager Integration', type: :integration do
  let(:api_public_key) { 'pk_test_123' }
  let(:api_secret_key) { 'sk_test_456' }
  let(:tinker) { Tinker::Payments.new(api_public_key: api_public_key, api_secret_key: api_secret_key) }

  describe '#initiate' do
    it 'initiates a payment request' do
      stub_auth_request
      stub_request(:post, 'https://sandbox-api.tinkerpayments.com/v1/merchant/payment/initiate')
        .with(
          headers: {
            'Authorization' => 'Bearer test_token',
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          },
          body: hash_including(
            amount: 100.0,
            currency: 'KES',
            gateway: 'mpesa',
            merchantReference: 'ORDER-12345'
          )
        )
        .to_return(
          status: 200,
          body: {
            success: true,
            data: {
              paymentReference: 'TXN-abc123',
              status: 'pending',
              authorization_url: 'https://example.com/auth'
            },
            meta: {
              request_id: 'req-auth-1',
              timestamp: '2026-02-11T22:52:45Z',
              environment: 'sandbox'
            }
          }.to_json
        )

      request = Tinker::Model::Dto::InitiatePaymentRequestDto.new(
        amount: 100.0,
        currency: 'KES',
        gateway: Tinker::Enum::Gateway::MPESA,
        merchant_reference: 'ORDER-12345',
        return_url: 'https://example.com/return'
      )

      transaction = tinker.transactions.initiate(request)

      expect(transaction).to be_a(Tinker::Model::Transaction)
      expect(transaction.initiation_data).to be_a(Tinker::Model::Dto::InitiationDataDto)
      expect(transaction.initiation_data.payment_reference).to eq('TXN-abc123')
    end
  end

  describe '#query' do
    it 'queries a payment' do
      stub_auth_request
      stub_request(:post, 'https://sandbox-api.tinkerpayments.com/v1/merchant/payment/query')
        .with(
          headers: {
            'Authorization' => 'Bearer test_token',
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          },
          body: {
            reference: 'TXN-abc123',
            gateway: 'mpesa'
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            success: true,
            data: {
              id: '123',
              reference: 'REF-123',
              status: 'success',
              amount: 100.0,
              currency: 'KES',
              created_at: '2024-01-01T00:00:00Z',
              channel: 'mpesa'
            },
            meta: {
              request_id: 'req-query-1',
              timestamp: '2026-02-11T22:52:45Z',
              environment: 'sandbox'
            }
          }.to_json
        )

      request = Tinker::Model::Dto::QueryPaymentRequestDto.new(
        payment_reference: 'TXN-abc123',
        gateway: Tinker::Enum::Gateway::MPESA
      )

      transaction = tinker.transactions.query(request)

      expect(transaction).to be_a(Tinker::Model::Transaction)
      expect(transaction.successful?).to be true
      expect(transaction.query_data.reference).to eq('REF-123')
    end
  end

  def stub_auth_request
    stub_request(:post, 'https://sandbox-api.tinkerpayments.com/v1/auth/token')
      .with(
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Accept' => 'application/json'
        }
      )
      .to_return(
        status: 200,
        body: {
          success: true,
          data: {
            token: 'test_token',
            expires_in: 3600
          },
          meta: {
            request_id: 'req-token-1',
            timestamp: '2026-02-11T22:52:45Z',
            environment: 'sandbox'
          }
        }.to_json
      )
  end
end
