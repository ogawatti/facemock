require 'spec_helper'

describe Facemock::GraphAPI::Error::FacebookApiException do
  let(:type) { "FacebookApiException" }

  describe '#type' do
    let(:error) { Facemock::GraphAPI::Error::FacebookApiException.new }
    subject { error.type }
    it { is_expected.to eq type }
  end

  describe Facemock::GraphAPI::Error::FacebookApiException::ServiceTemporarilyUnavailable do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::FacebookApiException::ServiceTemporarilyUnavailable.new }
      let(:message) { "Service temporarily unavailable" }
      let(:code) { 2 }
      let(:status) { 500 }

      it_behaves_like 'GraphAPI Error'
    end
  end
end
