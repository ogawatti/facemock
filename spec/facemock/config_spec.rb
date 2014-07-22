require 'spec_helper'
require 'pry'

describe Facemock::Config do
  let(:db_name) { ".test" }

  it 'should have a database module' do
    expect(Facemock::Config::Database).to be_truthy
  end

  describe '#default_database' do
    before do
      allow_any_instance_of(Facemock::Config::Database).to receive(:connect) { true }
      allow_any_instance_of(Facemock::Config::Database).to receive(:create_tables) { true }
      allow_any_instance_of(Facemock::Config::Database).to receive(:disconnect!) { true }
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
      allow_any_instance_of(Facemock::Config::Database).to receive(:connect) { true }
      allow_any_instance_of(Facemock::Config::Database).to receive(:create_tables) { true }
      allow_any_instance_of(Facemock::Config::Database).to receive(:disconnect!) { true }
    end

    context 'without argument' do
      subject { Facemock::Config.database }
      it { is_expected.to be_truthy }

      describe '.name' do
        subject { Facemock::Config.database.name }
        it { is_expected.not_to be_nil }
        it { is_expected.not_to be_empty }
      end
    end

    context 'with name options' do
      subject { Facemock::Config.database(db_name) }
      it { is_expected.to be_truthy }

      describe '.name' do
        subject { Facemock::Config.database(db_name).name }
        it { is_expected.to eq db_name }
      end
    end
  end

  describe '#reset_database' do
    context 'when does not set database' do
      subject { Facemock::Config.reset_database }
      it { is_expected.to eq nil }
    end

    context 'when already set database' do
      before do
        stub_const("Facemock::Config::Database::DEFAULT_DATABASE_NAME", db_name)
        Facemock::Config.database
      end

      subject { Facemock::Config.reset_database }
      it { is_expected.to eq nil }

      after { Facemock::Config.database.drop }
    end
  end
end
