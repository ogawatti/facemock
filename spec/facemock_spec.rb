require 'spec_helper'

describe Facemock do
  let(:version) { "0.0.2" }
  let(:db_name) { ".test" }

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

  before do
    stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
  end
  after  { Facemock::Config.database.drop }

  describe '#on' do
    subject { Facemock.on }
    it { is_expected.to be_truthy }

    context 'FbGraph' do
      context 'without option' do
        before { Facemock.on }
        it { expect(::FbGraph).to eq Facemock::FbGraph }
        it { expect( lambda { Facemock.on } ).not_to raise_error }
      end

      context 'with database_name option' do
        before do
          @options = { database_name: db_name}
          Facemock.on(@options)
        end
        it { expect(::FbGraph).to eq Facemock::FbGraph }
        it { expect( lambda { Facemock.on } ).not_to raise_error }
        it { expect( lambda { Facemock.on(@options) } ).not_to raise_error }
      end
    end
  end

  describe '#off' do
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
end
