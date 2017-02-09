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

    it 'delegate to `PaymentProcessor#perform!`' do
      mock_perform = Minitest::Mock.new
      mock_perform.expect(:perform!, nil)

      mock_new = Minitest::Mock.new
      mock_new.expect(:call, mock_perform, [api_response])

      subject.stub :response, api_response do
        Docproof::PaymentProcessor.stub(:new, mock_new) do
          subject.notarize!
        end
      end

      mock_new.verify
      mock_perform.verify
    end
  end
end
