require 'test_helper'
require 'support/coinbase'

describe Docproof::PaymentProcessor::Coinbase do
  let(:recipient) { 'bitcoinADDRESS' }
  let(:amount)    { 5_000_000 }

  subject do
    lambda do
      Docproof::PaymentProcessor::Coinbase.new(
        recipient: recipient,
        amount:    amount
      )
    end
  end

  describe '#new' do
    before { Docproof::PaymentProcessor::Coinbase.configuration = nil }
    after  { Docproof::PaymentProcessor::Coinbase.configuration = nil }

    let(:configuration) { Docproof::PaymentProcessor::Coinbase.configuration }
    let(:env) do
      {'COINBASE_API_KEY' => 'API_KEY', 'COINBASE_API_SECRET' => 'API_SECRET'}
    end

    describe 'when COINBASE_API_KEY and COINBASE_API_SECRET environment variables undefined' do
      it 'raise `MissingCredentials`' do
        -> { subject.call }.must_raise(
          Docproof::PaymentProcessor::MissingCredentials
        )
      end
    end

    describe 'when COINBASE_API_KEY and COINBASE_API_SECRET environment variables defined' do
      it 'take the API key and secret from environment variable' do
        ENV.stub :[], ->(key){ env[key] } do
          subject.call.must_be_instance_of(Docproof::PaymentProcessor::Coinbase)
        end

        configuration.api_key.must_equal    env['COINBASE_API_KEY']
        configuration.api_secret.must_equal env['COINBASE_API_SECRET']
      end
    end

    describe 'when it is configure via configure block' do
      let(:api_key)    { 'my-coinbase-api-key' }
      let(:api_secret) { 'my-coinbase-api-secret' }

      before do
        Docproof::PaymentProcessor::Coinbase.configure do |config|
          config.api_key    = api_key
          config.api_secret = api_secret
        end
      end

      it 'use the configuration instead of the environment variable' do
        ENV.stub :[], ->(key){ env[key] } do
          subject.call.must_be_instance_of(Docproof::PaymentProcessor::Coinbase)
        end

        configuration.api_key.must_equal    api_key
        configuration.api_secret.must_equal api_secret
      end
    end
  end

  describe '#perform!' do
    let(:coinbase_instance) { subject.call }

    it 'raise `MissingDependency` if coinbase is not installed' do
      ENV.stub :[], '<CREDENTIALS>' do
        ->{ coinbase_instance.perform! }.must_raise(
          Docproof::PaymentProcessor::MissingDependency
        )
      end
    end

    it 'call `Coinbase::Wallet::Client#primary_account` to `send` bitcoin' do
      send_method_call = Minitest::Mock.new
      send_method_call.expect(
        :send,
        nil,
        [{to: recipient, amount: amount, currency: 'BTC'}]
      )

      primary_account_method_call = Minitest::Mock.new
      primary_account_method_call.expect(:primary_account, send_method_call)

      coinbase_wallet_client = Minitest::Mock.new
      coinbase_wallet_client.expect(
        :call,
        primary_account_method_call,
        [{api_key: '<CREDENTIALS>', api_secret: '<CREDENTIALS>'}]
      )

      ENV.stub :[], '<CREDENTIALS>' do
        coinbase_instance.stub :require, true do
          ::Coinbase::Wallet::Client.stub(:new, coinbase_wallet_client) do
            coinbase_instance.perform!
          end
        end
      end

      coinbase_wallet_client.verify
      primary_account_method_call.verify
      send_method_call.verify
    end
  end
end