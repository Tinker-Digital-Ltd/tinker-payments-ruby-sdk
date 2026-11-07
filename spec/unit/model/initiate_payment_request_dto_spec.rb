# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Model::Dto::InitiatePaymentRequestDto do
  it 'serializes payment_method as paymentMethod and omits it when unset' do
    args = { amount: 100, currency: 'USD', gateway: 'stripe', merchant_reference: 'ORDER-1',
             return_url: 'https://example.com/return' }

    expect(described_class.new(**args, payment_method: 'apple_pay').to_hash[:paymentMethod]).to eq('apple_pay')
    expect(described_class.new(**args).to_hash).not_to have_key(:paymentMethod)
  end

  it 'serializes customer_name and country and omits them when unset' do
    args = { amount: 100, currency: 'EUR', gateway: 'adyen', merchant_reference: 'ORDER-1',
             return_url: 'https://example.com/return' }

    payload = described_class.new(**args, customer_name: 'Ada', country: 'DE').to_hash
    expect(payload).to include(customerName: 'Ada', country: 'DE')
    expect(described_class.new(**args).to_hash).not_to include(:customerName, :country)
  end

  it 'carries country on query data and payment webhook data only when sent' do
    data = { 'id' => '1', 'reference' => 'R', 'status' => 'authorised', 'amount' => 1, 'currency' => 'EUR' }
    expect(Tinker::Model::Dto::QueryDataDto.new(data.merge('country' => 'DE')).to_hash[:country]).to eq('DE')
    expect(Tinker::Model::Dto::QueryDataDto.new(data).to_hash).not_to have_key(:country)
    expect(Tinker::Webhook::Dto::PaymentEventDataDto.new(data.merge('country' => 'DE')).to_hash['country']).to eq('DE')
    expect(Tinker::Webhook::Dto::PaymentEventDataDto.new(data).to_hash).not_to have_key('country')
  end
end
