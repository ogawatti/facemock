require 'spec_helper'
require 'rack/test'

describe Facemock::GraphAPI::Application::Accounts::TestUsers do
  include TestApplicationHelper
  include Rack::Test::Methods

  let(:method) { 'GET' }
  let(:path)   { "/#{application.id}/accounts/test-users" }
  let(:application) { Facemock::Application.create! }
  let(:server_access_token) { application.create_server_token!.string }
  let(:test_app) { TestApplicationHelper::TestRackApplication.new }
  let(:app)      { Facemock::GraphAPI::Application::Accounts::TestUsers.new(test_app) }
  let(:db_name)  { ".test" }

  before { @database = Facemock::Database.new(db_name) }
  after  { @database.drop }

  describe 'METHOD' do
    subject { Facemock::GraphAPI::Application::Accounts::TestUsers::METHOD }
    it { is_expected.to eq method }
  end

  describe 'PATH' do
    subject { Facemock::GraphAPI::Application::Accounts::TestUsers::PATH }
    it { is_expected.to eq path.gsub(/#{application.id}/, ":application_id") }
  end

  # GET /:application_id/accounts/test-users?access_token=application_id|string27&limit=N
  describe 'GET /:appliation_id/accounts/test-users' do
    let(:response) { [ status, header, [ body ] ] }
    let(:header) { { "Content-Type"   => "application/json; charset=UTF-8",
                     "Content-Length" => body.size.to_s } }
    let(:query)  { "?" + params.inject([]){|a, (k,v)| a << "#{k}=#{v}"}.join("&") }

    before do
      @test_user_one    = Facemock::User.create!(role: Facemock::User::TEST_ROLE)
      @test_user_two    = Facemock::User.create!(role: Facemock::User::TEST_ROLE)
      options_one       = { application_id: application.id, user_id: @test_user_one.id }
      options_two       = { application_id: application.id, user_id: @test_user_two.id }
      @access_token_one = Facemock::AccessToken.create!(options_one)
      @access_token_two = Facemock::AccessToken.create!(options_two)
    end

    context 'when request is success' do
      let(:status) { 200 }
      let(:body)   { @body }
      let(:limit)  { "50" }
      let(:login_url_base) { "https://developers.facebook.com/checkpoint/test-user-login/" }

      shared_examples 'API 200 OK' do
        it 'should return 200 OK' do
          expect(last_response.status).to eq status
          header.each{|key, value| expect(last_response.header[key]).to eq value }
          expect(last_response.body).to eq body
        end
      end

      context 'with server access token' do
        let(:params) { { access_token: server_access_token } }

        before do
          @body = { "data"=> [ { "id"           => @test_user_one.id,
                                 "login_url"    => File.join(login_url_base, @test_user_one.id.to_s),
                                 "access_token" => @access_token_one.string },
                               { "id"           => @test_user_two.id,
                                 "login_url"    => File.join(login_url_base, @test_user_two.id.to_s),
                                 "access_token" => @access_token_two.string } ] }.to_json
          get path + URI.escape(query)
        end

        it_behaves_like 'API 200 OK'
      end

      # TODO & DOING : body["paging"] 対応
      context 'with server access token and limit 1 parameter' do
        let(:params) { { access_token: server_access_token, limit: 1 } }

        before do
          @body = { "data"   => [ { "id"           => @test_user_one.id,
                                 "login_url"    => File.join(login_url_base, @test_user_one.id.to_s),
                                 "access_token" => @access_token_one.string } ],
                    "paging" => { "cursors" => { "before" => "MTA1NDQ0MDE5Nzk0NTAy",
                                                 "after"  => "MTAwMDA3NzU0MjA2NDgw" },
                                  "next" => "https:\/\/graph.facebook.com\/v2.0\/889315667755023\/accounts?access_token=889315667755023\u00257CZ2-eROzAHeLo9UAVxsOtSjRFrpw&type=test-users&limit=1&after=MTM4MTc3MDA1NTQ2NTM3Mw\u00253D\u00253D" } }.to_json
          get path + URI.escape(query)
        end

        it_behaves_like 'API 200 OK'
      end

      # TODO : limit: 1, before: 先頭
      # TODO : limit: 1, before: 2番目
      # TODO : limit: 1, after:  先頭
      # TODO : limit: 1, after:  2番目
      # TODO : limit: 1, after:  先頭,  before: 先頭
      #  * index == "MTAwMDA4NTg2MzA0OTEy" とか "MTM4MTc3MDA1NTQ2NTM3Mw==" とか
      #  * ロジックは配列のと同じ感じ

      context 'with server access token and limit string parameter' do
        let(:params) { { access_token: server_access_token, limit: "test" } }

        before do
          @body = { "data"=> [] }.to_json
          get path + URI.escape(query)
        end

        it_behaves_like 'API 200 OK'
      end
    end

    context 'when request is failure' do
      let(:body) { error.to_json }
      let(:error) { { error: { message: message, type: type, code: code } } }

      context 'without server access token' do
        let(:message) { "An access token is required to request this resource." }
        let(:type)    { "OAuthException" }
        let(:code)    { 104 }
        before        { get path }
        it_behaves_like 'API 400 Bad Request'
      end

      context 'with invalid server access_token' do
        let(:message) { "Invalid OAuth access token signature." }
        let(:type)    { "OAuthException" }
        let(:code)    { 190 }
        let(:params)  { { access_token: "test_token" } }
        before        { get path + URI.escape(query) }
        it_behaves_like 'API 400 Bad Request'
      end

      context "because application id is the other's in path" do
        let(:message) { "Unsupported get request. Please read the Graph API documentation at https:\/\/developers.facebook.com\/docs\/graph-api" }
        let(:type)    { "GraphMethodException" }
        let(:code)    { 100 }
        let(:params)  { { access_token: server_access_token } }
        before do
          app_id = Facemock::Application.create!.id
          get path.gsub(/#{application.id}/, app_id.to_s) + URI.escape(query)
        end
        it_behaves_like 'API 400 Bad Request'
      end

      context 'with limit -1 parameter' do
        let(:message) { "An unknown error has occurred." }
        let(:type)    { "OAuthException" }
        let(:code)    { 1 }
        let(:params) { { access_token: server_access_token, limit: -1 } }
        before        { get path + URI.escape(query) }
        it_behaves_like 'API 500 Internal Server Error'
      end
    end
  end
end
