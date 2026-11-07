# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Enum::PaymentStatus do
  it 'defines PENDING constant' do
    expect(Tinker::Enum::PaymentStatus::PENDING).to eq('pending')
  end

  it 'defines SUCCESS constant' do
    expect(Tinker::Enum::PaymentStatus::SUCCESS).to eq('success')
  end

  it 'defines CANCELLED constant' do
    expect(Tinker::Enum::PaymentStatus::CANCELLED).to eq('cancelled')
  end

  it 'maps completed to success and keeps unknown statuses as sent' do
    expect(described_class.parse('completed')).to eq('success')
    expect(described_class.parse('reversed')).to eq(described_class::REVERSED)
    expect(described_class.parse('future_state')).to eq('future_state')
    expect(described_class.parse(nil)).to eq('pending')
  end

  it 'defines every spec status' do
    %w[pending authorised success failed blocked refunded partially_refunded cancelled expired reversed].each do |value|
      expect(described_class.constants.map { |name| described_class.const_get(name) }).to include(value)
    end
  end

  it 'defines FAILED constant' do
    expect(Tinker::Enum::PaymentStatus::FAILED).to eq('failed')
  end
end
