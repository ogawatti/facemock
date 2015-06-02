require 'spec_helper'

describe Facemock::GraphAPI::Error do
  before { @error = Facemock::GraphAPI::Error.new }
  let(:status)  { 500 }
  let(:header)  { { "Content-Type"   => "application/json; charset=UTF-8",
                    "Content-Length" => body.first.bytesize.to_s } }
  let(:body)    { [ error.to_json ] }
  let(:error)   { { error: { message: message, type: type, code: code } } }
  let(:message) { "Service temporarily unavailable" }
  let(:type)    { "FacebookApiException" }
  let(:code)    { 2 }

  describe '#response' do
    subject { @error.response }
    it { is_expected.to be_instance_of Facemock::GraphAPI::Error::Response }

    it 'should be include status and header, body' do
      expect(@error.response.size).to eq 3
      expect(@error.response[0]).to eq status
      expect(@error.response[1]).to eq header
      expect(@error.response[2]).to eq body
    end
  end

  describe '#to_hash' do
    context 'when status and message, type, code are nil' do
      subject { @error.to_hash }
      it { is_expected.to be_instance_of Hash }
      it { is_expected.to eq error }
    end

    context 'when status and message, type, code are not nil' do
      before do
        @error.message = "test error"
        @error.type    = "TestException"
        @error.code    = 0
      end

      it 'should include instance variables' do
        hash = @error.to_hash
        expect(hash).to be_instance_of Hash
        expect(hash[:error]).not_to be_nil
        expect(hash[:error][:message]).to eq @error.message
        expect(hash[:error][:type]).to eq @error.type
        expect(hash[:error][:code]).to eq @error.code
      end
    end
  end

  describe '#to_json' do
    subject { @error.to_json }
    it { is_expected.to eq @error.to_hash.to_json }
  end
end
