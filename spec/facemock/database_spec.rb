require 'spec_helper'

describe Facemock::Database do
  let(:default_db_name) { "facemock" }
  let(:adapter)         { "sqlite3" }
  let(:table_names)     { [:applications, :users, :user_rights] }
  let(:db_directory)    { File.expand_path("../../../db", __FILE__) }
  let(:db_filepath)     { File.join(db_directory, "#{db_name}.#{adapter}") }

  let(:db_name)         { ".test" }

  describe '::ADAPTER' do
    subject { Facemock::Database::ADAPTER }
    it { is_expected.to eq adapter }
  end

  describe '::DB_DIRECTORY' do
    subject { Facemock::Database::DB_DIRECTORY }
    it { is_expected.to eq db_directory }
  end

  describe '::TABLE_NAMES' do
    subject { Facemock::Database::TABLE_NAMES }
    it { is_expected.to eq table_names }
  end

  describe '::DEFAULT_DB_NAMES' do
    subject { Facemock::Database::DEFAULT_DB_NAME }
    it { is_expected.to eq default_db_name }
  end

  describe '#initialize' do
    before do
      allow_any_instance_of(Facemock::Database).to receive(:connect) { true }
      allow_any_instance_of(Facemock::Database).to receive(:create_tables) { true }
    end

    context 'with database name' do
      subject { lambda { Facemock::Database.new(db_name) } }
      it { is_expected.not_to raise_error }

      describe '.name' do
        subject { Facemock::Database.new(db_name).name }
        it { is_expected.to eq db_name }
      end
    end

    context 'without argument' do
      subject { lambda { Facemock::Database.new } }
      it { is_expected.not_to raise_error }

      describe '.name' do
        subject { Facemock::Database.new.name }
        it { is_expected.to eq default_db_name }
      end
    end

    context 'with nil or "" or default database name' do
      [nil, "", "facemock"].each do |argument|
        subject { lambda { Facemock::Database.new(argument) } }
        it { is_expected.not_to raise_error }

        describe '.name' do
          subject { Facemock::Database.new(argument).name }
          it { is_expected.to eq default_db_name }
        end
      end
    end
  end

  describe '#connect' do
    before do
      allow_any_instance_of(Facemock::Database).to receive(:create_tables) { true }
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
    end

    subject { lambda { @database.connect } }
    it { is_expected.not_to raise_error }
    it { expect(ActiveRecord::Base.connected?).to eq true }
    it { expect(File.exist?(@database.filepath)).to eq true }

    after { Facemock::Config.database.drop }
  end

  describe '#disconnect' do
    before do
      allow_any_instance_of(Facemock::Database).to receive(:create_tables) { true }
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
    end

    subject { lambda { @database.disconnect! } }
    it { is_expected.not_to raise_error }

    context 'when success' do
      describe 'datbase file is not removed' do
        before { @database.disconnect! }
        it { expect(File.exist?(@database.filepath)).to eq true }
      end
    end

    after { Facemock::Config.database.drop }
  end

  describe '#drop' do
    before do
      allow_any_instance_of(Facemock::Database).to receive(:create_tables) { true }
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
    end

    subject { lambda { @database.drop } }
    it { is_expected.not_to raise_error }

    context 'when success' do
      describe 'database file does not exist' do
        before { @database.drop }
        it { expect(File.exist?(@database.filepath)).to eq false }
      end

      describe 're-drop is success' do
        before { @database.drop }
        subject { lambda { @database.drop } }
        it { is_expected.not_to raise_error }
      end
    end

    after { Facemock::Config.database.drop }
  end

  describe '#clear' do
    before do
      allow_any_instance_of(Facemock::Database).to receive(:create_tables) { true }
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
      expect(@database).to receive(:drop_tables)
      expect(@database).to receive(:create_tables)
    end

    subject { @database.clear }
    it { is_expected.to be_truthy }

    after { Facemock::Config.database.drop }
  end

  describe '#create_tables' do
    before do
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
      @database.drop_tables
    end

    subject { lambda { @database.create_tables } }
    it { is_expected.not_to raise_error }

    after { Facemock::Config.database.drop }
  end

  describe '#drop_tables' do
    before do
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
    end

    subject { lambda { @database.drop_tables } }
    it { is_expected.not_to raise_error }

    after { Facemock::Config.database.drop }
  end

  describe '#filepath' do
    before do
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
    end

    subject { @database.filepath }
    it { is_expected.to eq db_filepath }

    context 'then database file is exist' do
      subject { File.exist? @database.filepath }
      it { is_expected.to eq true }
    end

    after { Facemock::Config.database.drop }
  end

  describe '#connected?' do
    before do
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Config.database
    end
    after { Facemock::Config.database.drop }

    context 'after new' do
      subject { @database.connected? }
      it { is_expected.to eq true }
    end

    context 'after disconnect!' do
      before do
        @database.disconnect!
      end

      subject { @database.connected? }
      it { is_expected.to eq false }
    end

    context 'after connect' do
      before do
        @database.disconnect!
        @database.connect
      end

      subject { @database.connected? }
      it { is_expected.to eq true }
    end
  end
end
