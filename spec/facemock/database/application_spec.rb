require 'spec_helper'

describe Facemock::Database::Application do
  include TableHelper

  let(:db_name)      { ".test" }

  let(:table_name)   { :applications }
  let(:column_names) { [ :id, :secret, :created_at ] }
  let(:children)     { [ Facemock::Database::User ] }

  let(:id)           { 1 }
  let(:secret)       { "test_secret" }
  let(:created_at)   { Time.now }
  let(:options)      { { id: id, secret: secret, created_at: created_at } }

  after { remove_dynamically_defined_all_method }

  describe '::TABLE_NAME' do
    subject { Facemock::Database::Application::TABLE_NAME }
    it { is_expected.to eq table_name }
  end

  describe '::COLUMN_NAMES' do
    subject { Facemock::Database::Application::COLUMN_NAMES }
    it { is_expected.to eq column_names }
  end

  describe '::CHILDREN' do
    subject { Facemock::Database::Application::CHILDREN }
    it { is_expected.to eq children }
  end

  describe '#initialize' do
    context 'without option' do
      subject { Facemock::Database::Application.new }
      it { is_expected.to be_kind_of Facemock::Database::Application }

      describe '.id' do
        subject { Facemock::Database::Application.new.id }
        it { is_expected.to be > 0 }
      end

      describe '.secret' do
        subject { Facemock::Database::Application.new.secret }
        it { is_expected.to be_kind_of String }

        describe '.size' do
          subject { Facemock::Database::Application.new.secret.size }
          it { is_expected.to be <= 32 }
        end
      end

      describe '.created_at' do
        subject { Facemock::Database::Application.new.created_at }
        it { is_expected.to be_nil }
      end
    end

    context 'with id option but it is not integer' do
      before { @opts = { id: "test_id" } }
      subject { Facemock::Database::Application.new(@opts) }
      it { is_expected.to be_kind_of Facemock::Database::Application }

      describe '.id' do
        subject { Facemock::Database::Application.new(@opts).id }
        it { is_expected.to be > 0 }
      end
    end

    context 'with all options' do
      subject { Facemock::Database::Application.new(options) }
      it { is_expected.to be_kind_of Facemock::Database::Application }

      context 'then attributes' do
        it 'should set specified values by option' do
          column_names.each do |column_name|
            value = Facemock::Database::Application.new(options).send(column_name)
            expect(value).to eq options[column_name]
          end
        end
      end
    end
  end

  describe 'destroy' do
    before do
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Database.new
    end
    after { @database.drop }

    context 'when has user' do
      before do
        @application = Facemock::Database::Application.create!
        Facemock::Database::User.create!(application_id: @application.id)
      end

      it 'should delete permissions' do
        @application.destroy
        users = Facemock::Database::User.find_all_by_application_id(@application.id)
        expect(users).to be_empty
      end
    end
  end
end
