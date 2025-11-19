# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tinker::Model::Transaction do
  describe '#initialize' do
    context 'with initiation data' do
      it 'creates transaction with initiation data' do
        data = {
          'payment_reference' => 'TXN-123',
          'status' => 'pending',
          'authorization_url' => 'https://example.com/auth'
        }

        transaction = Tinker::Model::Transaction.new(data)

        expect(transaction.initiation_data).to be_a(Tinker::Model::Dto::InitiationDataDto)
        expect(transaction.query_data).to be_nil
        expect(transaction.callback_data).to be_nil
      end
    end

    context 'with query/callback data' do
      it 'creates transaction with query and callback data' do
        data = {
          'id' => '123',
          'reference' => 'REF-123',
          'status' => 'success',
          'amount' => 100.0,
          'currency' => 'KES',
          'created_at' => '2024-01-01T00:00:00Z',
          'channel' => 'mpesa'
        }

        transaction = Tinker::Model::Transaction.new(data)

        expect(transaction.query_data).to be_a(Tinker::Model::Dto::QueryDataDto)
        expect(transaction.callback_data).to be_a(Tinker::Model::Dto::CallbackDataDto)
        expect(transaction.initiation_data).to be_nil
      end
    end
  end

  describe '#successful?' do
    it 'returns true for successful transactions' do
      data = {
        'id' => '123',
        'reference' => 'REF-123',
        'status' => 'success',
        'amount' => 100.0,
        'currency' => 'KES',
        'created_at' => '2024-01-01T00:00:00Z',
        'channel' => 'mpesa'
      }

      transaction = Tinker::Model::Transaction.new(data)
      expect(transaction.successful?).to be true
    end
  end

  describe '#pending?' do
    it 'returns true for pending transactions' do
      data = {
        'payment_reference' => 'TXN-123',
        'status' => 'pending'
      }

      transaction = Tinker::Model::Transaction.new(data)
      expect(transaction.pending?).to be true
    end
  end

  describe '#cancelled?' do
    it 'returns true for cancelled transactions' do
      data = {
        'id' => '123',
        'reference' => 'REF-123',
        'status' => 'cancelled',
        'amount' => 100.0,
        'currency' => 'KES',
        'created_at' => '2024-01-01T00:00:00Z',
        'channel' => 'mpesa'
      }

      transaction = Tinker::Model::Transaction.new(data)
      expect(transaction.cancelled?).to be true
    end
  end

  describe '#failed?' do
    it 'returns true for failed transactions' do
      data = {
        'id' => '123',
        'reference' => 'REF-123',
        'status' => 'failed',
        'amount' => 100.0,
        'currency' => 'KES',
        'created_at' => '2024-01-01T00:00:00Z',
        'channel' => 'mpesa'
      }

      transaction = Tinker::Model::Transaction.new(data)
      expect(transaction.failed?).to be true
    end
  end
end

