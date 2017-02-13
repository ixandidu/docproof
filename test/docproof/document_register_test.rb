require 'test_helper'

describe Docproof::Document do
  before do
    stub_request(:post, /proofofexistence.com/).to_rack(
      Docproof::Mocks::ProofOfExistence::FakeAPI
    )
  end

  describe '#register!' do
    describe 'registering a valid hash' do
      subject { Docproof::Document.new(:valid) }
      it      { subject.register!.must_be_instance_of Hash }

      describe '#response' do
        let(:response) { subject.response.keys }

        before { subject.register! }
        it     { response.must_include 'digest' }
        it     { response.must_include 'pay_address' }
        it     { response.must_include 'price' }
      end
    end

    describe 'registering an existing hash' do
      subject { Docproof::Document.new(:existing) }
      it      { ->{ subject.register! }.must_raise(Docproof::Document::Existed) }
    end

    describe 'registering an invalid hash' do
      subject { Docproof::Document.new(:invalid) }
       it     { ->{ subject.register! }.must_raise(Docproof::Document::Invalid) }
    end
  end
end
