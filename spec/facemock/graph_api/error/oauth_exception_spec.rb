require 'spec_helper'

describe Facemock::GraphAPI::Error::OAuthException do
  let(:type) { "OAuthException" }

  describe '#type' do
    let(:error) { Facemock::GraphAPI::Error::OAuthException.new }
    subject { error.type }
    it { is_expected.to eq type }
  end

  describe Facemock::GraphAPI::Error::OAuthException::InvalidOAuthAccessToken do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::InvalidOAuthAccessToken.new }
      let(:message) { "Invalid OAuth access token." }
      let(:code) { 190 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end

  describe Facemock::GraphAPI::Error::OAuthException::InvalidAccessToken do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::InvalidAccessToken.new }
      let(:message) { "Access token has expired, been revoked, or is otherwise invalid - Handle expired access tokens." }
      let(:code) { 467 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end

  describe Facemock::GraphAPI::Error::OAuthException::AccessTokenDoesNotExist do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::AccessTokenDoesNotExist.new }
      let(:message) { "An active access token must be used to query information about the current user." }
      let(:code) { 2500 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end
end
