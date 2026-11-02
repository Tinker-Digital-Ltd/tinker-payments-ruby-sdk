# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Model::Dto::InitiatePaymentRequestDto do
  it 'serializes payment_method as paymentMethod and omits it when unset' do
    args = { amount: 100, currency: 'USD', gateway: 'stripe', merchant_reference: 'ORDER-1',
             return_url: 'https://example.com/return' }

    expect(described_class.new(**args, payment_method: 'apple_pay').to_hash[:paymentMethod]).to eq('apple_pay')
    expect(described_class.new(**args).to_hash).not_to have_key(:paymentMethod)
  end
end
