require 'spec_helper'

describe Facemock::AccessToken do
  include TableHelper

  let(:db_name)        { ".test" }
  let(:table_name)      { :access_tokens }
  let(:column_names)    { [ :id, :string, :user_id, :application_id, :created_at ] }

  let(:id)              { 1 }
  let(:string)          { "test_code" }
  let(:user_id)         { 1 }
  let(:application_id)  { 1 }
  let(:created_at)      { Time.now }
  let(:options)         { { id:             id, 
                            string:         string, 
                            user_id:        user_id, 
                            application_id: application_id, 
                            created_at:     created_at } }

  after { remove_dynamically_defined_all_method }

  describe '#initialize' do
    context 'without option' do
      subject { Facemock::AccessToken.new }
      it { is_expected.to be_kind_of Facemock::AccessToken }

      context 'then attributes' do
        it 'should be nil except string' do
          column_names.each do |column_name|
            value = Facemock::AccessToken.new.send(column_name)
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
          string1 = Facemock::AccessToken.new.string
          string2 = Facemock::AccessToken.new.string
          expect(string1).to be_kind_of String
          expect(string1.size).to eq 255
          expect(string1).not_to eq string2
        end
      end
    end

    context 'with all options' do
      subject { Facemock::AccessToken.new(options) }
      it { is_expected.to be_kind_of Facemock::AccessToken }

      context 'then attributes' do
        it 'should set specified value by option' do
          column_names.each do |column_name|
            value = Facemock::AccessToken.new(options).send(column_name)
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

    context 'when has access_token and authorizaion_code' do
      before do
        application = Facemock::Application.create!
        @user = Facemock::User.create!
        options = { application_id: application.id, user_id: @user.id }
        @access_token = Facemock::AccessToken.create!(options)
        Facemock::Permission.create!(access_token_id: @access_token.id, name: "hoge")
      end

      it 'should delete permissions' do
        @access_token.destroy
        permissions = Facemock::Permission.find_all_by_access_token_id(@access_token.id)
        expect(permissions).to be_empty
      end
    end
  end
end
