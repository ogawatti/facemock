require 'spec_helper'

describe Facemock::GraphAPI::Error::OAuthException do
  let(:type) { "OAuthException" }

  describe '#type' do
    let(:error) { Facemock::GraphAPI::Error::OAuthException.new }
    subject { error.type }
    it { is_expected.to eq type }
  end

  describe Facemock::GraphAPI::Error::OAuthException::AnUnknownErrorHasOccurred do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::AnUnknownErrorHasOccurred.new }
      let(:message) { "An unknown error has occurred." }
      let(:code) { 1 }
      let(:status) { 500 }

      it_behaves_like 'GraphAPI Error'
    end
  end

  describe Facemock::GraphAPI::Error::OAuthException::ErrorValidatingClientSecret do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::ErrorValidatingClientSecret.new }
      let(:message) { "Error validating client secret." }
      let(:code) { 1 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end

  describe Facemock::GraphAPI::Error::OAuthException::MissingClientIDParameter do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::MissingClientIDParameter.new }
      let(:message) { "Missing client_id parameter." }
      let(:code) { 101 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end

  describe Facemock::GraphAPI::Error::OAuthException::ErrorValidatingApplication do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::ErrorValidatingApplication.new }
      let(:message) { "Error validating application. Cannot get application info due to a system error." }
      let(:code) { 101 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
  end

  describe Facemock::GraphAPI::Error::OAuthException::AccessTokenIsRequired do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::AccessTokenIsRequired.new }
      let(:message) { "An access token is required to request this resource." }
      let(:code) { 104 }
      let(:status) { 400 }

      it_behaves_like 'GraphAPI Error'
    end
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

  describe Facemock::GraphAPI::Error::OAuthException::MissingRedirectURIParameter do
    describe '#new' do
      let(:error) { Facemock::GraphAPI::Error::OAuthException::MissingRedirectURIParameter.new }
      let(:message) { "Missing redirect_uri parameter." }
      let(:code) { 191 }
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
