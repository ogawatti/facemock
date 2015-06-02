require 'spec_helper'

describe Facemock::GraphAPI do
  let(:hostname)    { 'graph.facebook.com' }
  let(:port)        { 443 }
  let(:middlewares) { [ Facemock::GraphAPI::Me, Facemock::GraphAPI::OAuth::AccessToken ] }

  describe '::HOSTNAME' do
    subject { Facemock::GraphAPI::HOSTNAME }
    it { is_expected.to eq hostname }
  end

  describe '::PORT' do
    subject { Facemock::GraphAPI::PORT }
    it { is_expected.to eq port }
  end

  describe '::MIDDLEWARES' do
    subject { Facemock::GraphAPI::MIDDLEWARES }
    it { is_expected.to eq middlewares }
  end

  describe '.on' do
    subject { Facemock::GraphAPI.on }
    it { is_expected.to eq true }
  end

  describe '.off' do
    subject { Facemock::GraphAPI.off }
    it { is_expected.to eq true }
  end

  describe '.on?' do
    context 'when graph api mock is on' do
      before  { Facemock::GraphAPI.on }
      after   { Facemock::GraphAPI.off }
      subject { Facemock::GraphAPI.on? }
      it { is_expected.to eq true }
    end

    context 'when graph api mock is off' do
      before  { Facemock::GraphAPI.off }
      subject { Facemock::GraphAPI.on? }
      it { is_expected.to eq false }
    end
  end

  describe '.app' do
    subject { Facemock::GraphAPI.app }
    it { is_expected.to be_instance_of middlewares.last }
  end
end
