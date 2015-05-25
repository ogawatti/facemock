require 'spec_helper'

describe Facemock::GraphAPI::Error::Response do
  describe '#new' do
    context 'without argument' do
      subject { lambda { Facemock::GraphAPI::Error::Response.new } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with status, header, body' do
      let(:response) { [ status, header, [ body ] ] }
      let(:status) { 200 }
      let(:header) { { test: "test header" } }
      let(:body)   { "test body" }

      subject { Facemock::GraphAPI::Error::Response.new(status, header, body) }
      it { is_expected.to eq response }

      describe '#status' do
        subject { Facemock::GraphAPI::Error::Response.new(status, header, body).status }
        it { is_expected.to eq status }
      end

      describe '#header' do
        subject { Facemock::GraphAPI::Error::Response.new(status, header, body).header }
        it { is_expected.to eq header }
      end

      describe '#body' do
        subject { Facemock::GraphAPI::Error::Response.new(status, header, body).body }
        it { is_expected.to eq body }
      end
    end
  end
end
