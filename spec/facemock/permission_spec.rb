require 'spec_helper'

describe Facemock::Permission do
  let(:db_name)         { ".test" }
  let(:column_names)    { [ :id, :name, :access_token_id, :created_at ] }

  let(:id)              { 1 }
  let(:name)            { "read_stream" }
  let(:access_token_id) { 1 }
  let(:created_at)      { Time.now }
  let(:options)         { { id: id, 
                            name: name, 
                            access_token_id: access_token_id, 
                            created_at: created_at } }

  describe '#initialize' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

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

  describe '#access_token' do
    before { @database = Facemock::Database.new(db_name) }
    after  { @database.drop }

    context 'when access_token_id is empty' do
      before { @permissions = Facemock::Permission.new }
      subject { @permissions.access_token }
      it { is_expected.to be_nil }
    end

    context 'when access_token_id is specified' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        options = { application_id: @application.id, user_id: @user.id }
        @access_token = Facemock::AccessToken.create!(options)
        @permissions = Facemock::Permission.new(access_token_id: @access_token.id)
      end

      subject { @permissions.access_token.id }
      it { is_expected.to eq @access_token.id }
    end
  end
end
