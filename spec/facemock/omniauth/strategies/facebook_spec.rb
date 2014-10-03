require 'spec_helper'

describe Facemock::OmniAuth::Strategies::Facebook do
  class TestApp; end
  let(:app)      { TestApp.new }
  let(:facebook) { Facemock::OmniAuth::Strategies::Facebook.new(app) }

  describe '#call!(env)' do
    context 'without argument' do
      subject { lambda { facebook.call! } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with correct argument' do
      context 'when request path equals Facemock::Login::PATH' do
        before do
          @env = { "PATH_INFO" => Facemock::Login.path }
          expect(Facemock::Login).to receive(:call).with(@env)
        end
        subject { lambda { facebook.call!(@env) } }
        it { is_expected.not_to raise_error }
      end

      context 'when request path equals Facemock::Authentication::PATH and request method is POST' do
        before do
          @env = { "PATH_INFO" => Facemock::Authentication.path,
                   "REQUEST_METHOD" => "POST" }
          expect(Facemock::Authentication).to receive(:call).with(@env)
        end
        subject { lambda { facebook.call!(@env) } }
        it { is_expected.not_to raise_error }
      end

      context 'when request path does not equal Facemock::Login::PATH' do
        before do
          @env = { "PATH_INFO" => "/" }
        end
        subject { lambda { facebook.call!(@env) } }
        it { is_expected.to raise_error OmniAuth::NoSessionError }
      end
    end
  end

  describe '#request_phase' do
    it 'should be Array and 302 facemock login url' do
      result = facebook.request_phase
      expect(result).to be_kind_of Array
      expect(result.size).to eq 3

      status, header, body = result

      expect(status).to be_kind_of Fixnum
      expect(status).to eq 302

      expect(header).to be_kind_of Rack::Utils::HeaderHash
      expect(header["Location"]).to eq Facemock::Login.path

      expect(body).to be_kind_of Rack::BodyProxy
    end
  end

  describe '#callback_phase' do
    # (protected) build_access_token の実装
  end

  describe '#raw_info' do
  end
end
