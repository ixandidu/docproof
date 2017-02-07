require 'test_helper'
require 'support/proof_of_existence'

describe Docproof::Document do
  before do
    stub_request(:post, /proofofexistence.com/).to_rack(
      ProofOfExistence::FakeAPI
    )
  end

  describe '#register!' do
    describe 'registering a valid hash' do
      subject { Docproof::Document.new(:valid_hash) }
      it      { subject.register!.must_be_instance_of Hash }

      describe '#response' do
        let(:response) { subject.response.keys }

        before { subject.register! }
        it     { response.must_include 'digest' }
        it     { response.must_include 'pay_address' }
        it     { response.must_include 'price' }
      end
    end

    describe 'registering an already registered hash' do
      subject { Docproof::Document.new(:existing_hash) }

      it 'raise an informative error on failure' do
        lambda { subject.register! }.must_raise(RuntimeError, /existing/)
      end
    end

    describe 'registering an invalid hash' do
      subject { Docproof::Document.new(:invalid_hash) }

      it 'raise an informative error on failure' do
        lambda { subject.register! }.must_raise(RuntimeError, /Invalid/)
      end
    end
  end

  describe '.lookup!' do
    describe 'looking up a pending hash' do
      subject { Docproof::Document.new(:pending_hash) }
      it      { subject.lookup!.must_be_instance_of Hash }

      describe '#response' do
        let(:response) { subject.response.keys }

        before { subject.lookup! }
        it     { response.wont_include 'tx' }
        it     { response.wont_include 'txstamp' }
        it     { response.wont_include 'blockstamp' }
      end
    end

    describe 'looking up a registered but unconfirmed hash' do
      subject { Docproof::Document.new(:registered_unconfirmed_hash) }
      it      { subject.lookup!.must_be_instance_of Hash }

      describe '#response' do
        let(:response) { subject.response.keys }

        before { subject.lookup! }
        it     { response.must_include 'tx'}
        it     { response.must_include 'txstamp'}
        it     { response.wont_include 'blockstamp' }
      end
    end

    describe 'looking up a registered and confirmed hash' do
      subject { Docproof::Document.new(:registered_confirmed_hash) }
      it      { subject.lookup!.must_be_instance_of Hash }

      describe '#response' do
        let(:response) { subject.response.keys }

        before { subject.lookup! }
        it     { response.must_include 'tx'}
        it     { response.must_include 'txstamp'}
        it     { response.must_include 'blockstamp' }
      end
    end

    describe 'looking up a nonexistent hash' do
      subject { Docproof::Document.new(:nonexistent_hash) }

      it 'raise an informative error on failure' do
        lambda { subject.lookup! }.must_raise(RuntimeError, /nonexistent/)
      end
    end
  end
end
