require 'spec_helper'
require 'rack/test'

describe Facemock::GraphAPI::OAuth::AccessToken do
  include TestApplicationHelper
  include Rack::Test::Methods

  let(:method) { 'POST' }
  let(:path)   { '/oauth/access_token' }
  let(:test_app) { TestApplicationHelper::TestRackApplication.new }
  let(:app)      { Facemock::GraphAPI::OAuth::AccessToken.new(test_app) }
  let(:db_name)  { ".test" }

  describe 'METHOD' do
    subject { Facemock::GraphAPI::OAuth::AccessToken::METHOD }
    it { is_expected.to eq method }
  end

  describe 'PATH' do
    subject { Facemock::GraphAPI::OAuth::AccessToken::PATH }
    it { is_expected.to eq path }
  end

  describe 'POST /oauth/access_token' do
    before { @database = Facemock::Database.new(db_name) }
    after  { @database.drop }
    let(:response) { [ status, header, [ body ] ] }
    let(:application) { Facemock::Application.create! }

    let(:request_body)  { { :grant_type    => grant_type,
                            :client_id     => application.id,
                            :client_secret => application.secret } }
    let(:grant_type)    { "client_credentials" }
    let(:client_id)     { application.id }
    let(:client_secret) { application.secret }

    context 'when request is success' do
      let(:status) { 200 }
      let(:body)   { "access_token=#{application.id}|xxxxxxxxxxxxxxxxxxxxxxxxxxx" }
      let(:header) { { "Content-Type"   => "text/plain; charset=UTF-8",
                       "Content-Length" => body.size.to_s } }

      context 'with body include client credentials grant type and with valid client id & secret' do
        before { post path, request_body }

        it 'should return 200 OK' do
          expect(last_response.status).to eq status
          header.each{|key, value| expect(last_response.header[key]).to eq value }
          expect(last_response.body).to match /access_token=#{application.id}\|.*/
        end
      end
    end

    context 'when request is failed' do
      let(:body)   { error.to_json }
      let(:header) { { "Content-Type"   => "application/json; charset=UTF-8",
                       "Content-Length" => body.bytesize.to_s } }
      let(:error)  { { error: { message: message, type: type, code: code } } }
      let(:type)    { "OAuthException" }

      context 'because of missing uri parameter' do
        let(:message) { "Missing redirect_uri parameter." }
        let(:code)    { 191 }

        context 'without body' do
          before do
            request_body = {}
            post path, request_body
          end
          it_behaves_like 'API 400 Bad Request'
        end

        context 'without grant type' do
          before do
            request_body.delete(:grant_type)
            post path, request_body
          end
          it_behaves_like 'API 400 Bad Request'
        end

        context 'with invalid grant type' do
          let(:grant_type) { "test" }
          before { post path, request_body }
          it_behaves_like 'API 400 Bad Request'
        end
      end

      context 'because of client id is missing' do
        let(:message) { "Missing client_id parameter." }
        let(:code)    { 101 }

        before do
          request_body.delete(:client_id)
          post path, request_body
        end
        it_behaves_like 'API 400 Bad Request'
      end

      context 'because of client id is invalid' do
        let(:message) { "An unknown error has occurred." }
        let(:code)    { 1 }

        before do
          request_body[:client_id] = "test"
          post path, request_body
        end
        it_behaves_like 'API 500 Internal Server Error'
      end

      context 'because of client id is the other application' do
        let(:message) { "Error validating application. Cannot get application info due to a system error." }
        let(:code)    { 101 }

        before do
          request_body[:client_id] = 100
          post path, request_body
        end
        it_behaves_like 'API 400 Bad Request'
      end

      context 'because of client secret is invalid' do
        let(:message) { "Error validating client secret." }
        let(:code)    { 1 }

        context 'without client secret' do
          before do
            request_body.delete(:client_secret)
            post path, request_body
          end
          it_behaves_like 'API 400 Bad Request'
        end

        context 'with invalid client secret' do
          before do 
            request_body[:client_secret] = "test_secret"
            post path, request_body
          end
          it_behaves_like 'API 400 Bad Request'
        end
      end
    end
  end
end
