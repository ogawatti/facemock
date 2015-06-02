require 'spec_helper'

describe Facemock::User do
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

  describe '#initialize' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

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

  describe '#access_token' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'when does not have access_token' do
      before { @user = Facemock::User.new }
      subject { @user.access_tokens }
      it { is_expected.to be_empty }
    end

    context 'when have some access_tokens' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        options = { application_id: @application.id, user_id: @user.id }
        @access_token1 = Facemock::AccessToken.create!(options)
        @access_token2 = Facemock::AccessToken.create!(options)
      end

      subject { @user.access_tokens }
      it { is_expected.not_to be_empty }

      it 'should include its' do
        expect(@user.access_tokens.first.id).to eq @access_token1.id
        expect(@user.access_tokens.last.id).to eq @access_token2.id
      end
    end
  end

  describe '#authorization_code' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'when does not have access_token' do
      before { @user = Facemock::User.new }
      subject { @user.access_tokens }
      it { is_expected.to be_empty }
    end

    context 'when have some access_tokens' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        options = { application_id: @application.id, user_id: @user.id }
        @authorization_code1 = Facemock::AuthorizationCode.create!(options)
        @authorization_code2 = Facemock::AuthorizationCode.create!(options)
      end

      subject { @user.authorization_codes }
      it { is_expected.not_to be_empty }

      it 'should include its' do
        expect(@user.authorization_codes.first.id).to eq @authorization_code1.id
        expect(@user.authorization_codes.last.id).to eq @authorization_code2.id
      end
    end
  end

  describe '#destroy' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'when has access tokens and authorization codes' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        options = { application_id: @application.id, user_id: @user.id }
        2.times do
          Facemock::AccessToken.create!(options)
          Facemock::AuthorizationCode.create!(options)
        end
      end

      it 'should delete access tokens and authorization codes' do
        @user.destroy
        access_tokens = Facemock::AccessToken.find_all_by_user_id(@user.id)
        authorization_codes = Facemock::AuthorizationCode.find_all_by_user_id(@user.id)
        expect(access_tokens).to be_empty
        expect(authorization_codes).to be_empty
      end
    end
  end

  describe '#to_hash' do
    before { @user = Facemock::User.new }

    it 'should be include user info' do
      hash = @user.to_hash
      expect(hash).to be_instance_of Hash
      expect(hash[:id]).to eq @user.id
      expect(hash[:first_name]).to eq @user.name.split.first
      expect(hash[:gender]).to eq "male"
      expect(hash[:last_name]).to eq @user.name.split.last
      expect(hash[:link]).to eq "http://www.facebook.com/#{@user.id}"
      expect(hash[:locale]).to eq "ja_JP"
      expect(hash[:name]).to eq @user.name
      expect(hash[:timezone]).to eq 9
      expect(hash[:updated_time]).to eq Time.parse("2014/07/22")
      expect(hash[:verified]).to eq true
    end
  end

  describe '#to_json' do
    before { @user = Facemock::User.new }
    subject { @user.to_json }
    it { is_expected.to eq @user.to_hash.to_json }
  end
end
