require 'spec_helper'

describe Facemock::Application do
  include TableHelper

  let(:db_name)      { ".test" }

  let(:table_name)   { :applications }
  let(:column_names) { [ :id, :secret, :created_at ] }

  let(:id)           { 1 }
  let(:secret)       { "test_secret" }
  let(:created_at)   { Time.now }
  let(:options)      { { id: id, secret: secret, created_at: created_at } }

  after { remove_dynamically_defined_all_method }

  describe '#initialize' do
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

  describe 'destroy' do
    before do
      stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
      @database = Facemock::Database.new
    end
    after { @database.drop }

    context 'when has user' do
      before do
        @application = Facemock::Application.create!
        @user = Facemock::User.create!
        Facemock::AccessToken.create!(application_id: @application.id, user_id: @user.id)
      end

      it 'should delete access_tokens' do
        @application.destroy
        access_tokens = Facemock::AccessToken.find_all_by_application_id(@application.id)
        authorization_codes = Facemock::AuthorizationCode.find_all_by_user_id(@user.id)
        expect(access_tokens).to be_empty
        expect(authorization_codes).to be_empty
        user = Facemock::User.find_by_id(@user.id)
        expect(user).not_to be_nil
      end
    end
  end
end
