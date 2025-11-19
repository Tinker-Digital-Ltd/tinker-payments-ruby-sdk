# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Config::Configuration do
  describe '#initialize' do
    it 'sets API keys and base URL' do
      config = Tinker::Config::Configuration.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456'
      )

      expect(config.api_public_key).to eq('pk_test_123')
      expect(config.api_secret_key).to eq('sk_test_456')
      expect(config.base_url).to eq("#{Tinker::Config::Endpoints::API_BASE_URL}/")
    end
  end

  describe '#api_key' do
    it 'returns the secret key' do
      config = Tinker::Config::Configuration.new(
        api_public_key: 'pk_test_123',
        api_secret_key: 'sk_test_456'
      )

      expect(config.api_key).to eq('sk_test_456')
    end
  end
end

