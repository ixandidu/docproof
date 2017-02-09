require 'test_helper'
require 'support/coinbase'

describe Docproof::PaymentProcessor do
  describe '#bitcoin_address' do
    [
      {'pay_address' => 'bitcoinADDRESS'},
      {'payment_address' => 'bitcoinADDRESS'}
    ].each do |options|
      specify do
        payment_processor = Docproof::PaymentProcessor.new(options)

        payment_processor.bitcoin_address.wont_be_nil
      end
    end
  end

  describe '#price_in_btc' do
    specify do
      options           = {'price' => 5000_000}
      payment_processor = Docproof::PaymentProcessor.new(options)

      payment_processor.price_in_btc.must_equal(
        options['price'].to_f / Docproof::PaymentProcessor::BTC_IN_SATOSHIS
      )
    end

    specify do
      payment_processor = Docproof::PaymentProcessor.new

      payment_processor.price_in_btc.must_equal(
        Docproof::PaymentProcessor::MINIMUM_PRICE_IN_BTC
      )
    end
  end

  describe '#perform!' do
    subject { Docproof::PaymentProcessor.new }

    it 'raise `MissingDependency` if coinbase is not installed' do
      ->{ subject.perform! }.must_raise(
        Docproof::PaymentProcessor::MissingDependency
      )
    end

    it 'raise `MissingCredentials` if coinbase credentials is not configure' do
      subject.stub :require, true do
        ->{ subject.perform! }.must_raise(
          Docproof::PaymentProcessor::MissingCredentials
        )
      end
    end

    it 'call `Coinbase::Wallet::Client#primary_account` to `send` bitcoin' do
      send_method_call = Minitest::Mock.new
      send_method_call.expect(
        :send,
        nil,
        [{to: nil, amount: Docproof::PaymentProcessor::MINIMUM_PRICE_IN_BTC, currency: 'BTC'}]
      )

      primary_account_method_call = Minitest::Mock.new
      primary_account_method_call.expect(:primary_account, send_method_call)

      coinbase_wallet_client = Minitest::Mock.new
      coinbase_wallet_client.expect(
        :call,
        primary_account_method_call,
        [{api_key: '<CREDENTIALS>', api_secret: '<CREDENTIALS>'}]
      )

      subject.stub :require, true do
        ENV.stub :fetch, '<CREDENTIALS>' do
          Coinbase::Wallet::Client.stub(:new, coinbase_wallet_client) do
            subject.perform!
          end
        end
      end

      coinbase_wallet_client.verify
      primary_account_method_call.verify
      send_method_call.verify
    end
  end
end
