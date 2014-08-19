require 'spec_helper'

describe Facemock::Database::Permission do
  let(:table_name)      { :permissions }
  let(:column_names)    { [ :id, :name, :user_id, :created_at ] }

  let(:id) { 1 }
  let(:name) { "read_stream" }
  let(:user_id) { 1 }
  let(:created_at) { Time.now }
  let(:options) { { id: id, name: name, user_id: user_id, created_at: created_at } }

  describe '::TABLE_NAME' do
    subject { Facemock::Database::Permission::TABLE_NAME }
    it { is_expected.to eq table_name }
  end

  describe '::COLUMN_NAMES' do
    subject { Facemock::Database::Permission::COLUMN_NAMES }
    it { is_expected.to eq column_names }
  end

  describe '#initialize' do
    context 'without option' do
      subject { Facemock::Database::Permission.new }
      it { is_expected.to be_kind_of Facemock::Database::Permission }

      context 'then attributes' do
        it 'should be nil' do
          column_names.each do |column_name|
            value = Facemock::Database::Permission.new.send(column_name)
            expect(value).to be_nil
          end
        end
      end
    end

    context 'with all options' do
      subject { Facemock::Database::Permission.new(options) }
      it { is_expected.to be_kind_of Facemock::Database::Permission }

      context 'then attributes' do
        it 'should set specified value by option' do
          column_names.each do |column_name|
            value = Facemock::Database::Permission.new(options).send(column_name)
            expect(value).to eq options[column_name]
          end
        end
      end
    end
  end
end
