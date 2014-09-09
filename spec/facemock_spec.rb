require 'spec_helper'

describe Facemock do
  let(:version) { '0.0.9' }
  let(:db_name) { '.test' }

  describe 'VERSION' do
    subject { Facemock::VERSION }
    it { is_expected.to eq version }
  end

  describe '.on' do
    subject { Facemock.on }
    it { is_expected.to be_truthy }

    context 'FbGraph' do
      before { Facemock.on }
      it { expect(::FbGraph).to eq Facemock::FbGraph }
      it { expect( lambda { Facemock.on } ).not_to raise_error }
    end
  end

  describe '.off' do
    subject { Facemock.off }
    it { is_expected.to be_truthy }

    context 'FbGraph' do
      before { Facemock.off }
      it { expect(FbGraph).to eq FbGraph }
      it { expect( lambda { Facemock.off } ).not_to raise_error }

      context 'when Mock is on' do
        before do
          Facemock.on
          Facemock.off
        end

        subject { ::FbGraph }
        it { is_expected.to eq FbGraph }
      end
    end
  end

  describe '.on?' do
    context 'when Facemock.off' do
      before { Facemock.off }
      subject { Facemock.on? }
      it { is_expected.to be true }
    end

    context 'when Facemock.on' do
      before { Facemock.on }
      after { Facemock.off }
      subject { Facemock.on? }
      it { is_expected.to be true }
    end
  end

  describe '.auth_hash' do
    context 'withou argument' do
      subject { Facemock.auth_hash }
      it { is_expected.to be_kind_of Facemock::AuthHash }
      it { is_expected.to be_empty }
    end

    context 'with incorrect argument' do
      it 'should return empty hash' do
        [nil, false, true, 1, ""].each do |argument|
          value = Facemock.auth_hash(argument)
          expect(value).to be_kind_of Facemock::AuthHash
          expect(value).to be_empty
        end
      end
    end

    context 'with access_token' do
      before do
        stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
        @database = Facemock::Database.new
        application = Facemock::Application.create!
        @user = Facemock::User.create!(application_id: application.id)
        @access_token = @user.access_token
      end
      after { @database.drop }

      context 'that is incorrect' do
      end

      context 'that is correct' do
        it 'should return AuthHash with some keys and value' do
          auth_hash = Facemock.auth_hash(@access_token)
          expect(auth_hash).to be_kind_of Facemock::AuthHash
          expect(auth_hash).not_to be_empty
          expect(auth_hash.provider).to eq "facebook"
          expect(auth_hash.uid).to eq @user.id
          [ auth_hash.info, auth_hash.credentials,
            auth_hash.extra, auth_hash.extra.raw_info ].each do |value|
            expect(value).to be_kind_of Hash
          end
          expect(auth_hash.info.name).to eq @user.name
          expect(auth_hash.credentials.token).to eq @user.access_token
          expect(auth_hash.credentials.expires_at).to be > Time.now
          expect(auth_hash.extra.raw_info.id).to eq @user.id
          expect(auth_hash.extra.raw_info.name).to eq @user.name
        end
      end
    end
  end
end
