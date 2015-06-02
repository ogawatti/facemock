require 'spec_helper'

describe Facemock::AuthorizationCode do
  let(:db_name)        { ".test" }
  let(:column_names)   { [ :id, :string, :user_id, :application_id, :created_at ] }

  let(:id)             { 1 }
  let(:string)         { "test_code" }
  let(:user_id)        { 1 }
  let(:application_id) { 1 }
  let(:created_at)     { Time.now }
  let(:options)        { { id:             id, 
                           string:         string, 
                           user_id:        user_id, 
                           application_id: application_id, 
                           created_at:     created_at } }

  describe '#initialize' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

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

  describe '#application' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'when application_id is empty' do
      before { @authorization_code = Facemock::AuthorizationCode.new }
      subject { @authorization_code.application }
      it { is_expected.to be_nil }
    end

    context 'when application_id is specified' do
      before do
        @application = Facemock::Application.create!
        @authorization_code = Facemock::AuthorizationCode.new(application_id: @application.id)
      end

      subject { @authorization_code.application.id }
      it { is_expected.to eq @application.id }
    end
  end

  describe '#user' do
    before { @database = Facemock::Database.new(db_name) }
    after  { @database.drop }

    context 'when user_id is empty' do
      before { @authorization_code = Facemock::AuthorizationCode.new }
      subject { @authorization_code.application }
      it { is_expected.to be_nil }
    end

    context 'when user_id is specified' do
      before do
        @user = Facemock::User.create!
        @authorization_code = Facemock::AuthorizationCode.new(user_id: @user.id)
      end

      subject { @authorization_code.user.id }
      it { is_expected.to eq @user.id }
    end
  end
end
