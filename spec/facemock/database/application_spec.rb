require 'spec_helper'

describe Facemock::Database::Application do
  let(:table_name)      { :applications }
  let(:column_names)    { [:id, :secret, :created_at] }

  let(:id)      { 1 }
  let(:secret)  { "test_secret" }
  let(:created_at) { Time.now }
  let(:options) { { id: id, secret: secret, created_at: created_at } }

  describe '::TABLE_NAME' do
    subject { Facemock::Database::Application::TABLE_NAME }
    it { is_expected.to eq table_name }
  end

  describe '::COLUMN_NAMES' do
    subject { Facemock::Database::Application::COLUMN_NAMES }
    it { is_expected.to eq column_names }
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
          it { is_expected.to eq 128 }
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
end
