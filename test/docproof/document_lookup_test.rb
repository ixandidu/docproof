require 'test_helper'
require 'support/proof_of_existence'

describe Docproof::Document do
  before do
    stub_request(:post, /proofofexistence.com/).to_rack(
      ProofOfExistence::FakeAPI
    )
  end

  describe '#lookup!' do
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
        it     { response.must_include 'tx' }
        it     { response.must_include 'txstamp' }
        it     { response.wont_include 'blockstamp' }
      end
    end

    describe 'looking up a registered and confirmed hash' do
      subject { Docproof::Document.new(:registered_confirmed_hash) }
      it      { subject.lookup!.must_be_instance_of Hash }

      describe '#response' do
        let(:response) { subject.response.keys }

        before { subject.lookup! }
        it     { response.must_include 'tx' }
        it     { response.must_include 'txstamp' }
        it     { response.must_include 'blockstamp' }
      end
    end

    describe 'looking up a nonexistent hash' do
      subject { Docproof::Document.new(:nonexistent_hash) }
      it      { ->{ subject.lookup! }.must_raise(Docproof::Document::NotFound) }
    end
  end
end