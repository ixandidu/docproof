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

  before { Docproof::PaymentProcessor::Coinbase.configuration = nil }

  describe '#new' do
    let(:configuration) { Docproof::PaymentProcessor::Coinbase.configuration }
    let(:env) do
      {
        'COINBASE_API_KEY'    => 'API_KEY',
        'COINBASE_API_SECRET' => 'API_SECRET',
        'COINBASE_ACCOUNT_ID' => 'ACCOUNT_ID'
      }
    end

    describe 'when it is not configure using `configure` method' do
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
          configuration.account_id.must_equal env['COINBASE_ACCOUNT_ID']
        end
      end
    end

    describe 'when it is configure via configure block' do
      let(:api_key)    { 'my-coinbase-api-key' }
      let(:api_secret) { 'my-coinbase-api-secret' }
      let(:account_id) { 'my-coinbase-account-id' }

      before do
        Docproof::PaymentProcessor::Coinbase.configure do |config|
          config.api_key    = api_key
          config.api_secret = api_secret
          config.account_id = account_id
        end
      end

      it 'use the configuration instead of the environment variable' do
        ENV.stub :[], ->(key){ env[key] } do
          subject.call.must_be_instance_of(Docproof::PaymentProcessor::Coinbase)
        end

        configuration.api_key.must_equal    api_key
        configuration.api_secret.must_equal api_secret
        configuration.account_id.must_equal account_id
      end
    end

    describe 'when it is configure via configure without block' do
      let(:configuration_hash) do
        {
          'api_key'    => 'my-other-coinbase-api-key',
          'api_secret' => 'my-other-coinbase-api-secret',
          'account_id' => 'my-other-coinbase-account-id'
        }
      end

      before do
        Docproof::PaymentProcessor::Coinbase.configure(configuration_hash)
      end

      it 'use the configuration hash instead of the environment variable' do
        ENV.stub :[], ->(key){ env[key] } do
          subject.call.must_be_instance_of(Docproof::PaymentProcessor::Coinbase)
        end

        configuration.api_key.must_equal    configuration_hash['api_key']
        configuration.api_secret.must_equal configuration_hash['api_secret']
        configuration.account_id.must_equal configuration_hash['account_id']
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

    describe 'when account id is not specified' do
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

        ENV.stub :[], ->(key){ key != 'COINBASE_ACCOUNT_ID' ? '<CREDENTIALS>' : nil } do
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

    describe 'when account id is specified' do
      it 'call `Coinbase::Wallet::Client#account(account_id)` to `send` bitcoin' do
        send_method_call = Minitest::Mock.new
        send_method_call.expect(
          :send,
          nil,
          [{to: recipient, amount: amount, currency: 'BTC'}]
        )

        account_method_call = Minitest::Mock.new
        account_method_call.expect(:account, send_method_call, ['<CREDENTIALS>'])

        coinbase_wallet_client = Minitest::Mock.new
        coinbase_wallet_client.expect(
          :call,
          account_method_call,
          [{api_key: '<CREDENTIALS>', api_secret: '<CREDENTIALS>'}]
        )

        ENV.stub :[], ->(key){ '<CREDENTIALS>' } do
          coinbase_instance.stub :require, true do
            ::Coinbase::Wallet::Client.stub(:new, coinbase_wallet_client) do
              coinbase_instance.perform!
            end
          end
        end

        coinbase_wallet_client.verify
        account_method_call.verify
        send_method_call.verify
      end
    end
  end
end
