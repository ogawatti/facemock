require 'spec_helper'
require 'tempfile'

describe Facemock::Config do
  let(:db_name) { ".test" }
  let(:ymlfile) { "testdata.yml" }

  before { stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name) }

  describe '#default_database' do
    before do
      allow_any_instance_of(Facemock::Database).to receive(:connect) { true }
      allow_any_instance_of(Facemock::Database).to receive(:create_tables) { true }
      allow_any_instance_of(Facemock::Database).to receive(:disconnect!) { true }
    end

    subject { Facemock::Config.default_database }
    it { is_expected.to be_truthy }

    describe '.name' do
      subject { Facemock::Config.default_database.name }
      it { is_expected.not_to be_nil }
      it { is_expected.not_to be_empty }
    end
  end

  describe '#database' do
    before do
      allow_any_instance_of(Facemock::Database).to receive(:connect) { true }
      allow_any_instance_of(Facemock::Database).to receive(:create_tables) { true }
      allow_any_instance_of(Facemock::Database).to receive(:disconnect!) { true }
    end

    subject { Facemock::Config.database }
    it { is_expected.to be_truthy }

    describe '.name' do
      subject { Facemock::Config.database.name }
      it { is_expected.not_to be_nil }
      it { is_expected.not_to be_empty }
    end
  end

  describe '#reset_database' do
    context 'when does not set database' do
      subject { Facemock::Config.reset_database }
      it { is_expected.to eq nil }
    end

    context 'when already set database' do
      before do
        stub_const("Facemock::Database::DEFAULT_DATABASE_NAME", db_name)
        @database = Facemock::Database.new
      end

      subject { Facemock::Config.reset_database }
      it { is_expected.to eq nil }

      after { @database.drop }
    end
  end
end
