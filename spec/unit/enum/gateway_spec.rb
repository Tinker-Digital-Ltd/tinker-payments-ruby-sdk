# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Enum::Gateway do
  it 'defines MPESA constant' do
    expect(Tinker::Enum::Gateway::MPESA).to eq('mpesa')
  end

  it 'defines PAYSTACK constant' do
    expect(Tinker::Enum::Gateway::PAYSTACK).to eq('paystack')
  end

  it 'defines STRIPE constant' do
    expect(Tinker::Enum::Gateway::STRIPE).to eq('stripe')
  end
end

