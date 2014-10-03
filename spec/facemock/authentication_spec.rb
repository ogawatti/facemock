require 'spec_helper'
require 'stringio'

describe Facemock::Authentication do
  let(:path)          { "/facemock/authentication" }
  let(:scheme)        { "http" }
  let(:host)          { "localhost" }
  let(:callback_path) { "/users/auth/facebook/callback" }
  let(:login_path)    { Facemock::Login.path }
  let(:email)         { "test@example.co.jp" }
  let(:password)      { "testpass" }

  describe '::PATH' do
    subject { Facemock::Authentication::PATH }
    it { is_expected.to eq path }
  end

  describe '::CALLBACK_PATH' do
    subject { Facemock::Authentication::CALLBACK_PATH }
    it { is_expected.to eq callback_path }
  end

  describe '.call' do
    context 'without argument' do
      subject { lambda { Facmeock::Authentication.call } }
      it { is_expected.to raise_error NameError }
    end

    context 'with argument' do
      before do
        @env = Hash.new
        @env['rack.url_scheme'] = scheme
        @env["HTTP_HOST"]       = host
        @env['rack.input']      = StringIO.new("email=#{email}&pass=#{password}", "r+")
      end

      context 'if user find by email' do
        before do
          user = Facemock::User.new( { emial: email, password: password } )
          expect(Facemock::User).to receive(:find_by_email).with(email) { user }
          @code = Facemock::AuthorizationCode.new
          expect(Facemock::AuthorizationCode).to receive(:create!) { @code }
        end

        it 'should return Array for redirect callback' do
          response = Facemock::Authentication.call(@env)
          expect(response).to be_kind_of Array
          expect(response.size).to eq 3

          status, header, body = response

          expect(status).to be_kind_of Fixnum
          expect(status).to eq 302

          expect(header).to be_kind_of Hash
          expect(header["Content-Type"]).to eq "text/html;charset=utf-8"
          expect(header["Content-Length"]).to eq 0.to_s
          location = "#{scheme}://#{host}#{callback_path}?code=#{@code.string}"
          expect(header["Location"]).to eq location

          expect(body).to eq []
        end
      end

      context 'if user does not found' do
        before do
          expect(Facemock::User).to receive(:find_by_email).with(email) { nil }
        end

        it 'should return Array for redirect login view' do
          response = Facemock::Authentication.call(@env)
          expect(response).to be_kind_of Array
          expect(response.size).to eq 3

          status, header, body = response

          expect(header).to be_kind_of Hash
          expect(status).to be_kind_of Fixnum
          expect(status).to eq 302

          expect(header["Content-Type"]).to eq "text/html;charset=utf-8"
          expect(header["Content-Length"]).to eq 0.to_s
          location = "#{scheme}://#{host}#{login_path}"
          expect(header["Location"]).to eq location

          expect(body).to eq []
        end
      end
    end
  end

  describe '.path' do
    subject { Facemock::Authentication.path }
    it { is_expected.to eq Facemock::Authentication::PATH }
  end

  describe '.callback_path' do
    subject { Facemock::Authentication.callback_path }
    it { is_expected.to eq Facemock::Authentication::CALLBACK_PATH }
  end
end
