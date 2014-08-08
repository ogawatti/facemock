require 'spec_helper'

describe Facemock::FbGraph::Application do
  let(:facebook_app_id) { 100000000000000 }
  let(:facebook_app_secret) { "test_secret" }
  let(:access_token) { "access_token" }

  let(:db_name) { ".test" }
  let(:adapter)       { "sqlite3" }
  let(:db_directory)  { File.expand_path("../../../../db", __FILE__) }
  let(:db_filepath)   { File.join(db_directory, "#{db_name}.#{adapter}") }

  it 'should have a user class' do
    expect(Facemock::FbGraph::Application::User).to be_truthy
    expect(Facemock::FbGraph::Application::User.ancestors).to include Facemock::Database::User
  end

  it 'should have a users class' do
    expect(Facemock::FbGraph::Application::TestUsers).to be_truthy
    expect(Facemock::FbGraph::Application::TestUsers.ancestors).to include Array
  end

  before do
    stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
    Facemock::Config.database
  end
  after  { Facemock::Config.database.drop }

  describe '#new' do
    context 'without argument' do
      subject { lambda { Facemock::FbGraph::Application.new } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with facebook app id and secret' do
      before { @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret) }

      describe '.identifier' do
        subject { @app.identifier }
        it { is_expected.to eq facebook_app_id }
      end

      describe '.secreet' do
        subject { @app.secret }
        it { is_expected.to eq facebook_app_secret }
      end
    end

    context 'with facebook app id and secret' do
      before do
        options = { secret: facebook_app_secret }
        Facemock::FbGraph.on
        @app = Facemock::FbGraph::Application.new(facebook_app_id, options)
      end

      describe '.identifier' do
        subject { @app.identifier }
        it { is_expected.to eq facebook_app_id }
      end

      describe '.secreet' do
        subject { @app.secret }
        it { is_expected.to eq facebook_app_secret }
      end
    end

    context 'with app symbole and access_token' do
      before { @app = Facemock::FbGraph::Application.new(:app, access_token: access_token) }

      describe '.identifier' do
        subject { @app.identifier }
        it { is_expected.to be_kind_of Integer }
      end

      describe '.secreet' do
        subject { @app.secret }
        it { is_expected.not_to be_empty }
      end
    end
  end

  describe '#fetch' do
    before { @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret) }

    describe '.identifier' do
      subject { @app.fetch.identifier }
      it { is_expected.to eq @app.identifier }
    end

    describe '.secret' do
      subject { @app.fetch.secret }
      it { is_expected.to eq @app.secret }
    end
  end

  describe '#test_user!' do
    before { @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret) }

    it 'should created user' do
      expect(Facemock::FbGraph::Application::User.all).to be_empty
      created_user = @app.test_user!
      finded_user = Facemock::FbGraph::Application::User.find_by_id(created_user.id)
      Facemock::FbGraph::Application::User.column_names.each do |column_name|
        expect(created_user.send(column_name)).to eq finded_user.send(column_name)
      end
    end
  end
  
  describe '#test_users' do
    before do
      @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
    end

    context 'when test_user is not created' do
      subject { @app.test_users }

      it { is_expected.to be_kind_of Facemock::FbGraph::Application::TestUsers }
      it { is_expected.to be_empty }
    end

    context 'when test_user is created' do
      before do
        @user = @app.test_user!
      end

      subject { @app.test_users }
      it { is_expected.to be_kind_of Facemock::FbGraph::Application::TestUsers }
      it { is_expected.not_to be_empty }

      describe '.first.id' do
        subject { @app.test_users.first.id }
        it { is_expected.to eq @user.id }
      end
    end
  end
end
