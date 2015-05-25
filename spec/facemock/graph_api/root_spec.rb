require 'spec_helper'
require 'rack/test'

describe Facemock::GraphAPI::Root do
  include TestApplicationHelper
  include Rack::Test::Methods

  let(:method) { 'GET' }
  let(:path)   { '/' }
  let(:test_app) { TestApplicationHelper::TestRackApplication.new }
  let(:app)      { Facemock::GraphAPI::Root.new(test_app) }
  let(:db_name)      { ".test" }

  describe 'METHOD' do
    subject { Facemock::GraphAPI::Root::METHOD }
    it { is_expected.to eq method }
  end

  describe 'PATH' do
    subject { Facemock::GraphAPI::Root::PATH }
    it { is_expected.to eq path }
  end

  describe 'GET /' do
    let(:response) { [ status, header, [ body ] ] }
    let(:status)   { 400 }
    let(:header)   { { "Content-Type"   => "application/json; charset=UTF-8",
                       "Content-Length" => body.bytesize.to_s } }
    let(:body)     { error.to_json }
    let(:error)    { { error: { message: message, type: type, code: code } } }
    let(:message)  { "Unsupported get request. Please read the Graph API documentation at https:\/\/developers.facebook.com\/docs\/graph-api" }
    let(:type)     { "GraphMethodException" }
    let(:code)     { 100 }

    before { get path }
    it_behaves_like 'API 400 Bad Request'
  end
end
