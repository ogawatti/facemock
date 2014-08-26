require 'spec_helper'

describe Facemock do
  let(:version) { '0.0.5' }
  let(:db_name) { '.test' }

  describe 'VERSION' do
    subject { Facemock::VERSION }
    it { is_expected.to eq version }
  end

  it 'should have a config module' do
    expect(Facemock::Config).to be_truthy
  end

  it 'should have a fb_graph module' do
    expect(Facemock::FbGraph).to be_truthy
  end

  it 'should have a database class' do
    expect(Facemock::Database).to be_truthy
  end

  it 'should have a errors module' do
    expect(Facemock::Errors).to be_truthy
  end

  describe '.on' do
    subject { Facemock.on }
    it { is_expected.to be_truthy }

    context 'FbGraph' do
      before { Facemock.on }
      it { expect(::FbGraph).to eq Facemock::FbGraph }
      it { expect( lambda { Facemock.on } ).not_to raise_error }
    end
  end

  describe '.off' do
    subject { Facemock.off }
    it { is_expected.to be_truthy }

    context 'FbGraph' do
      before { Facemock.off }
      it { expect(FbGraph).to eq FbGraph }
      it { expect( lambda { Facemock.off } ).not_to raise_error }

      context 'when Mock is on' do
        before do
          Facemock.on
          Facemock.off
        end

        subject { ::FbGraph }
        it { is_expected.to eq FbGraph }
      end
    end
  end

  describe '.on?' do
    context 'when Facemock.off' do
      before { Facemock.off }
      subject { Facemock.on? }
      it { is_expected.to be true }
    end

    context 'when Facemock.on' do
      before { Facemock.on }
      after { Facemock.off }
      subject { Facemock.on? }
      it { is_expected.to be true }
    end
  end
end
