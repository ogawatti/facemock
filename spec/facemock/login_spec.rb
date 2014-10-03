require 'spec_helper'

describe Facemock::Login do
  let(:path) { "/facemock/sign_in" }
  let(:view_directory) { File.expand_path("../../../view", __FILE__) }
  let(:view_filename)  { "login.html" }
  let(:view_filepath)  { File.join(view_directory, view_filename) }

  describe '::PATH' do
    subject { Facemock::Login::PATH }
    it { is_expected.to eq path }
  end

  describe '::VIEW_DIRECTORY' do
    subject { Facemock::Login::VIEW_DIRECTORY }
    it { is_expected.to eq view_directory }
  end

  describe '::VIEW_FILE_NAME' do
    subject { Facemock::Login::VIEW_FILENAME }
    it { is_expected.to eq view_filename }
  end

  describe '.call' do
    context 'without argument' do
      subject { lambda { Facmeock::Login.call } }
      it { is_expected.to raise_error NameError }
    end

    context 'with argument' do
      before { @env = Hash.new }

      it 'should return Array with status code and header, body' do
        response = Facemock::Login.call(@env)
        expect(response).to be_kind_of Array
        expect(response.size).to eq 3

        status, header, body = response

        expect(status).to be_kind_of Fixnum
        expect(status).to eq 200

        body_size = body.first.bytesize
        expect(header).to be_kind_of Hash
        expect(header["Content-Type"]).to eq "text/html;charset=utf-8"
        expect(header["Content-Length"]).to eq body_size.to_s

        expect(body).to be_kind_of Array
        expect(body.size).to eq 1
        expect(body.first).to be_kind_of String
        expect(body.first).to eq Facemock::Login.view
      end
    end
  end

  describe '.path' do
    subject { Facemock::Login::PATH }
    it { is_expected.to eq path }
  end

  describe '.view' do
    before do 
      @html = "<html><body>Test page.</body></html>"
      expect(File).to receive(:read).with(view_filepath).once { @html }
    end
    subject { Facemock::Login.view }
    it { is_expected.to eq @html }
  end
end
