require 'spec_helper'
require 'rack/test'

describe Facemock::GraphAPI::Me do
  include TestApplicationHelper
  include Rack::Test::Methods

  let(:method) { 'GET' }
  let(:path)   { '/me' }
  let(:test_app) { TestApplicationHelper::TestRackApplication.new }
  let(:app)      { Facemock::GraphAPI::Me.new(test_app) }
  let(:db_name)      { ".test" }

  describe 'METHOD' do
    subject { Facemock::GraphAPI::Me::METHOD }
    it { is_expected.to eq method }
  end

  describe 'PATH' do
    subject { Facemock::GraphAPI::Me::PATH }
    it { is_expected.to eq path }
  end

  describe 'GET /me' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }
    let(:response) { [ status, header, [ body ] ] }
    let(:header) { { "Content-Type"   => "application/json; charset=UTF-8",
                     "Content-Length" => body.bytesize.to_s } }

    context 'when request is success' do
      let(:status) { 200 }
      let(:body) { @user.to_hash.to_json }

      context 'with access token in query string' do
        before do
          application = Facemock::Application.create!
          @user = Facemock::User.create!
          options = { application_id: application.id, user_id: @user.id }
          access_token = Facemock::AccessToken.create!(options)
          get path + "?access_token=#{access_token.string}"
        end

        it 'should return 200 OK' do
          expect(last_response.status).to eq status
          header.each{|key, value| expect(last_response.header[key]).to eq value }
          expect(last_response.body).to eq body
        end
      end

      # for Server Side Access
      context 'with access token and appsecret_proof header in query string and header' do
        before do
          application = Facemock::Application.create!
          @user = Facemock::User.create!
          options = { application_id: application.id, user_id: @user.id }
          access_token = Facemock::AccessToken.create!(options)

          appsecret_proof = OpenSSL::HMAC.hexdigest(
            OpenSSL::Digest::SHA256.new,
            application.secret,
            access_token.string
          )
          request_body   = nil
          request_header = { "Authorization" => "OAuth #{access_token.string}" }

          get path + "?appsecret_proof=#{appsecret_proof}", request_body, request_header
        end

        it 'should return 200 OK' do
          expect(last_response.status).to eq status
          header.each{|key, value| expect(last_response.header[key]).to eq value }
          expect(last_response.body).to eq body
        end
      end
    end

    context 'when request is failed' do
      let(:body) { error.to_json }
      let(:error) { { error: { message: message, type: type, code: code } } }

      context 'without access token' do
        let(:message) { "An active access token must be used to query information about the current user." }
        let(:type)    { "OAuthException" }
        let(:code)    { 2500 }
        before        { get path }
        it_behaves_like 'API 400 Bad Request'
      end

      context 'with access token is does not exist' do
        let(:message) { "Invalid OAuth access token." }
        let(:type)    { "OAuthException" }
        let(:code)    { 190 }
        before        { get path + "?access_token=aaa" }
        it_behaves_like 'API 400 Bad Request'
      end

      context 'with invalid access token' do
        let(:message) { "Access token has expired, been revoked, or is otherwise invalid - Handle expired access tokens." }
        let(:type)    { "OAuthException" }
        let(:code)    { 467 }
        before do
          application = Facemock::Application.create!
          options = { application_id: application.id, user_id: 1 }
          access_token = Facemock::AccessToken.create!(options)
          get path + "?access_token=#{access_token.string}"
        end
        it_behaves_like 'API 400 Bad Request'
      end

      context 'with valid access token and invalid app secret proof' do
        let(:message) { "Invalid appsecret_proof provided in the API argument" }
        let(:type)    { "GraphMethodException" }
        let(:code)    { 100 }
        before do
          application = Facemock::Application.create!
          user = Facemock::User.create!
          options = { application_id: application.id, user_id: user.id }
          access_token = Facemock::AccessToken.create!(options)

          appsecret_proof = "test_appsecret_proof"
          request_body   = nil
          request_header = { "Authorization" => "OAuth #{access_token.string}" }

          get path + "?appsecret_proof=#{appsecret_proof}", request_body, request_header
        end
        it_behaves_like 'API 400 Bad Request'
      end

      context 'with invalid access token and valid app secret proof' do
        let(:status)  { 401 }
        let(:message) { "Invalid OAuth access token." }
        let(:type)    { "OAuthException" }
        let(:code)    { 190 }
        before do
          application = Facemock::Application.create!
          user = Facemock::User.create!
          options = { application_id: application.id, user_id: user.id }
          access_token = Facemock::AccessToken.create!(options)

          appsecret_proof = OpenSSL::HMAC.hexdigest(
            OpenSSL::Digest::SHA256.new,
            application.secret,
            access_token.string
          )
          request_body   = nil
          request_header = { "Authorization" => "OAuth testtoken" }

          get path + "?appsecret_proof=#{appsecret_proof}", request_body, request_header
        end
        it_behaves_like 'API 401 Unauthorized'
      end

      context 'with invalid access token and invalid app secret proof' do
        let(:status)  { 401 }
        let(:message) { "Invalid OAuth access token." }
        let(:type)    { "OAuthException" }
        let(:code)    { 190 }
        before do
          appsecret_proof = "test_appsecret_proof"
          request_body   = nil
          request_header = { "Authorization" => "OAuth testtoken" }

          get path + "?appsecret_proof=#{appsecret_proof}", request_body, request_header
        end
        it_behaves_like 'API 401 Unauthorized'
      end
    end
  end
end
