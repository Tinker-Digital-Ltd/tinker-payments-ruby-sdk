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

  it 'defines FAILED constant' do
    expect(Tinker::Enum::PaymentStatus::FAILED).to eq('failed')
  end
end
