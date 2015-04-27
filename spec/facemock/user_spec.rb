require 'spec_helper'

describe Facemock::User do
  include TableHelper

  let(:db_name)        { ".test" }
  let(:table_name)     { :users }
  let(:column_names)   { [ :id,
                           :name,
                           :email,
                           :password,
                           :created_at ] }

  let(:id)             { 1 }
  let(:name)           { "test user" }
  let(:email)          { "hoge@fugapiyo.com" }
  let(:password)       { "testpass" }
  let(:created_at)     { Time.now }
  let(:options)        { { id:             id, 
                           name:           name,
                           email:          email,
                           password:       password,
                           created_at:     created_at } }

  after { remove_dynamically_defined_all_method }

  describe '#initialize' do
    context 'without option' do
      subject { Facemock::User.new }
      it { is_expected.to be_kind_of Facemock::User }

      describe '.id' do
        subject { Facemock::User.new.id }
        it { is_expected.to be > 0 }
        it { is_expected.to be < 100010000000000 }
      end

      describe '.name' do
        subject { Facemock::User.new.name }
        it { is_expected.to be_kind_of String }

        describe '.size' do
          subject { Facemock::User.new.name.size }
          it { is_expected.to be > 0 }
        end
      end

      describe '.email' do
        before { @user = Facemock::User.new }
        subject { @user.email }
        it { is_expected.to be_kind_of String }
        it { is_expected.to match /^.+@.+$/ }
      end

      describe '.password' do
        subject { Facemock::User.new.password }
        it { is_expected.to be_kind_of String }

        describe '.size' do
          subject { Facemock::User.new.password.size }
          it { is_expected.to be_between(8, 16) }
        end
      end

      describe '.created_at' do
        subject { Facemock::User.new.created_at }
        it { is_expected.to be_nil }
      end
    end

    context 'with id option but it is not integer' do
      before { @opts = { id: "test_id" } }
      subject { Facemock::User.new(@opts) }
      it { is_expected.to be_kind_of Facemock::User }

      describe '.id' do
        subject { Facemock::User.new(@opts).id }
        it { is_expected.to be > 0 }
        it { is_expected.to be < 100010000000000 }
      end
    end

    context 'with identifier option' do
      before { @opts = { identifier: 100010000000000 } }
      subject { Facemock::User.new(@opts) }
      it { is_expected.to be_kind_of Facemock::User }

      describe '.id' do
        subject { Facemock::User.new(@opts).id }
        it { is_expected.to eq @opts[:identifier] }
      end

      describe '.identifier' do
        subject { Facemock::User.new(@opts).identifier }
        it { is_expected.to eq @opts[:identifier] }
      end
    end

    context 'with all options' do
      subject { Facemock::User.new(options) }
      it { is_expected.to be_kind_of Facemock::User }

      context 'then attributes' do
        it 'should set specified value by option' do
          column_names.each do |column_name|
            value = Facemock::User.new(options).send(column_name)
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
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        Facemock::AccessToken.create!(application_id: @application.id, user_id: @user.id)
        Facemock::AuthorizationCode.create!(application_id: @application.id, user_id: @user.id)
      end

      it 'should delete permissions' do
        @user.destroy
        access_tokens = Facemock::AccessToken.find_all_by_user_id(@user.id)
        authorization_codes = Facemock::AuthorizationCode.find_all_by_user_id(@user.id)
        expect(access_tokens).to be_empty
        expect(authorization_codes).to be_empty
        application = Facemock::Application.find_by_id(@application.id)
        expect(application).not_to be_nil
      end
    end
  end

  describe '.access_tokens' do
    before do
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Database.new
    end
    after { @database.drop }

    context 'when does not create access_token record' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
      end

      subject { @user.access_tokens }
      it { is_expected.to be_empty }
    end

    context 'when has already created access_token record' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        @access_token_one   = Facemock::AccessToken.create!(application_id: @application.id, user_id: @user.id)
        @access_token_two   = Facemock::AccessToken.create!(application_id: @application.id, user_id: @user.id)
        @access_token_three = Facemock::AccessToken.create!(application_id: @application.id, user_id: @user.id + 1)
      end

      it 'should return AccessToken classes' do
        access_tokens = @user.access_tokens
        expect(access_tokens.size).to eq 2
        expect(access_tokens.first.id).to eq @access_token_one.id
        expect(access_tokens.last.id).to eq @access_token_two.id
      end
    end
  end
end
