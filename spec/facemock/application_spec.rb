require 'spec_helper'

describe Facemock::Application do
  let(:db_name)      { ".test" }
  let(:column_names) { [ :id, :secret, :created_at ] }
  let(:id)           { 1 }
  let(:secret)       { "test_secret" }
  let(:created_at)   { Time.now }
  let(:options)      { { id: id, secret: secret, created_at: created_at } }

  describe '#initialize' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'without option' do
      subject { Facemock::Application.new }
      it { is_expected.to be_kind_of Facemock::Application }

      describe '.id' do
        subject { Facemock::Application.new.id }
        it { is_expected.to be > 0 }
        it { is_expected.to be < 1000000000000000 }
      end

      describe '.secret' do
        subject { Facemock::Application.new.secret }
        it { is_expected.to be_kind_of String }

        describe '.size' do
          subject { Facemock::Application.new.secret.size }
          it { is_expected.to eq 32 }
        end
      end

      describe '.created_at' do
        subject { Facemock::Application.new.created_at }
        it { is_expected.to be_nil }
      end
    end

    context 'with id option but it is not integer' do
      before { @opts = { id: "test_id" } }
      subject { Facemock::Application.new(@opts) }
      it { is_expected.to be_kind_of Facemock::Application }

      describe '.id' do
        subject { Facemock::Application.new(@opts).id }
        it { is_expected.to be > 0 }
      end
    end

    context 'with all options' do
      subject { Facemock::Application.new(options) }
      it { is_expected.to be_kind_of Facemock::Application }

      context 'then attributes' do
        it 'should set specified values by option' do
          column_names.each do |column_name|
            value = Facemock::Application.new(options).send(column_name)
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
      before { @application = Facemock::Application.create! }
      subject { @application.access_tokens }
      it { is_expected.to be_empty }
    end

    context 'when have any permissions' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        options = { application_id: @application.id, user_id: @user.id }
        @access_token1 = Facemock::AccessToken.create!(options)
        @access_token2 = Facemock::AccessToken.create!(options)
      end

      subject { @application.access_tokens }
      it { is_expected.not_to be_empty }

      it 'should include its' do
        expect(@application.access_tokens.first.id).to eq @access_token1.id
        expect(@application.access_tokens.last.id).to eq @access_token2.id
      end
    end
  end

  describe '#authorization_code' do
    before { @database = Facemock::Database.new(db_name) }
    after { @database.drop }

    context 'when does not have access_token' do
      before { @application = Facemock::Application.create! }
      subject { @application.access_tokens }
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

      subject { @application.authorization_codes }
      it { is_expected.not_to be_empty }

      it 'should include its' do
        expect(@application.authorization_codes.first.id).to eq @authorization_code1.id
        expect(@application.authorization_codes.last.id).to eq @authorization_code2.id
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
        @application.destroy
        access_tokens = Facemock::AccessToken.find_all_by_application_id(@application.id)
        authorization_codes = Facemock::AuthorizationCode.find_all_by_application_id(@application.id)
        expect(access_tokens).to be_empty
        expect(authorization_codes).to be_empty
      end
    end
  end
end
