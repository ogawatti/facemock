require 'spec_helper'

describe Facemock::Permission do
  include TableHelper

  let(:table_name)      { :permissions }
  let(:column_names)    { [ :id, :name, :access_token_id, :created_at ] }

  let(:id)              { 1 }
  let(:name)            { "read_stream" }
  let(:access_token_id) { 1 }
  let(:created_at)      { Time.now }
  let(:options)         { { id: id, 
                            name: name, 
                            access_token_id: access_token_id, 
                            created_at: created_at } }

  after { remove_dynamically_defined_all_method }

  describe '#initialize' do
    context 'without option' do
      subject { Facemock::Permission.new }
      it { is_expected.to be_kind_of Facemock::Permission }

      context 'then attributes' do
        it 'should be nil' do
          column_names.each do |column_name|
            value = Facemock::Permission.new.send(column_name)
            expect(value).to be_nil
          end
        end
      end
    end

    context 'with all options' do
      subject { Facemock::Permission.new(options) }
      it { is_expected.to be_kind_of Facemock::Permission }

      context 'then attributes' do
        it 'should set specified value by option' do
          column_names.each do |column_name|
            value = Facemock::Permission.new(options).send(column_name)
            expect(value).to eq options[column_name]
          end
        end
      end
    end
  end
end
