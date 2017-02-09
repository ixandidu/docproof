require 'test_helper'

describe Docproof::Document do
  describe '#notarize!' do
    subject            { Docproof::Document.new(:the_sha256_hash) }
    let(:api_response) { {key: 'value'} }

    it 'raise `AlreadyNotarized` if the api response include transaction id' do
      subject.stub :response, {'tx' => 'A-TRANSCTION-ID'} do
        ->{ subject.notarize! }.must_raise(Docproof::Document::AlreadyNotarized)
      end
    end

    it 'call `PaymentProcessor#perform!`' do
      perform_method_call = Minitest::Mock.new
      perform_method_call.expect(:perform!, nil)

      payment_processor = Minitest::Mock.new
      payment_processor.expect(:call, perform_method_call, [api_response])

      subject.stub :response, api_response do
        Docproof::PaymentProcessor.stub(:new, payment_processor) do
          subject.notarize!
        end
      end

      payment_processor.verify
      perform_method_call.verify
    end
  end
end
