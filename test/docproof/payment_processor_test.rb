require 'test_helper'

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
      options           = {'price' => 5_000_000}
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
    let(:bitcoin_address) { 'bitcoinADDRESS' }
    let(:price_in_btc)    { 500_000 }

    subject { Docproof::PaymentProcessor.new }

    it 'call `Coinbase#perform!`' do
      perform_method_call = Minitest::Mock.new
      perform_method_call.expect(:perform!, nil)

      coinbase = Minitest::Mock.new
      coinbase.expect(
        :call,
        perform_method_call,
        [recipient: bitcoin_address, amount: price_in_btc]
      )

      subject.stub :bitcoin_address, bitcoin_address do
        subject.stub :price_in_btc, price_in_btc do
          Docproof::PaymentProcessor::Coinbase.stub(:new, coinbase) do
            subject.perform!
          end
        end
      end

      coinbase.verify
      perform_method_call.verify
    end
  end
end
