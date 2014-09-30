require 'spec_helper'

describe Facemock::AuthorizationCode do
  include TableHelper

  let(:table_name)   { :authorization_codes }
  let(:column_names) { [ :id, :string, :user_id, :created_at ] }
  let(:children)     { [] }

  let(:id)           { 1 }
  let(:string)       { "test_code" }
  let(:user_id)      { 1 }
  let(:created_at)   { Time.now }
  let(:options)      { { id: id, string: string, user_id: user_id, created_at: created_at } }

  after { remove_dynamically_defined_all_method }

  describe '::TABLE_NAME' do
    subject { Facemock::AuthorizationCode::TABLE_NAME }
    it { is_expected.to eq table_name }
  end

  describe '::COLUMN_NAMES' do
    subject { Facemock::AuthorizationCode::COLUMN_NAMES }
    it { is_expected.to eq column_names }
  end

  describe '::CHILDREN' do
    subject { Facemock::AuthorizationCode::CHILDREN }
    it { is_expected.to eq children }
  end

  describe '#initialize' do
    context 'without option' do
      subject { Facemock::AuthorizationCode.new }
      it { is_expected.to be_kind_of Facemock::AuthorizationCode }

      context 'then attributes' do
        it 'should be nil except string' do
          column_names.each do |column_name|
            value = Facemock::AuthorizationCode.new.send(column_name)
            if column_name == :string
              expect(value).not_to be_nil
            else
              expect(value).to be_nil
            end
          end
        end
      end

      context 'then string' do
        it 'should be random string' do
          string1 = Facemock::AuthorizationCode.new.string
          string2 = Facemock::AuthorizationCode.new.string
          expect(string1).to be_kind_of String
          expect(string1.size).to eq 255
          expect(string1).not_to eq string2
        end
      end
    end

    context 'with all options' do
      subject { Facemock::AuthorizationCode.new(options) }
      it { is_expected.to be_kind_of Facemock::AuthorizationCode }

      context 'then attributes' do
        it 'should set specified value by option' do
          column_names.each do |column_name|
            value = Facemock::AuthorizationCode.new(options).send(column_name)
            expect(value).to eq options[column_name]
          end
        end
      end
    end
  end
end
