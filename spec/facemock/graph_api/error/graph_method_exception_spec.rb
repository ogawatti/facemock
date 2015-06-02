require 'spec_helper'

describe Facemock::GraphAPI::Error::GraphMethodException do
  let(:type) { "GraphMethodException" }

  describe '#type' do
    let(:error) { Facemock::GraphAPI::Error::GraphMethodException.new }
    subject { error.type }
    it { is_expected.to eq type }
  end

  describe Facemock::GraphAPI::Error::GraphMethodException::UnsupportedGetRequest do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::GraphMethodException::UnsupportedGetRequest.new }
      let(:message) { "Unsupported get request. Please read the Graph API documentation at https:\/\/developers.facebook.com\/docs\/graph-api" }
      let(:code) { 100 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end

  describe Facemock::GraphAPI::Error::GraphMethodException::InvalidAppSecretProof do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::GraphMethodException::InvalidAppSecretProof.new }
      let(:message) { "Invalid appsecret_proof provided in the API argument" }
      let(:code) { 100 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end
end
