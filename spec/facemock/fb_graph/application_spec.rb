require 'spec_helper'

describe Facemock::FbGraph::Application do
  include ApplicationCreateHelper

  let(:db_name)      { ".test" }

  let(:facebook_app_id) { 100000000000000 }
  let(:facebook_app_secret) { "test_secret" }
  let(:access_token) { "access_token" }

  before do
    stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
    @database = Facemock::Database.new
  end
  after  { @database.drop }

  describe '#new' do
    before { @default_record_size = Facemock::Database::Application.all.size }

    context 'without argument' do
      subject { lambda { Facemock::FbGraph::Application.new } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with facebook app id' do
      shared_context 'new is success and record creates', assert: :attributes_and_created_record do
        it 'should set only identifier specified value by argument and record create' do
          expect(@app.identifier).to eq @id
          expect(@app.secret).to be_nil
          expect(@app.access_token).to be_nil
          expect(Facemock::Database::Application.all.size).to eq @default_record_size
        end
      end

      context 'when facebook app id is integer', assert: :attributes_and_created_record do
        before do
          @id  = facebook_app_id
          @app = Facemock::FbGraph::Application.new(facebook_app_id)
        end
      end

      context 'when facebook app id is numerical string', assert: :attributes_and_created_record do
        before do
          @id = facebook_app_id.to_s
          @app = Facemock::FbGraph::Application.new(@id)
        end
      end

      context 'when facebook app id is :app' do
        before do
          @id = :app
          @app = Facemock::FbGraph::Application.new(@id)
        end

        it 'should set only identifier specified value by argument and record does not create' do
          expect(@app.identifier).to eq @id
          expect(@app.secret).to be_nil
          expect(@app.access_token).to be_nil
          expect(Facemock::Database::Application.all.size).to eq @default_record_size
        end
      end

      context 'and all options' do
        before do
          @options = { secret: facebook_app_secret, access_token: access_token }
          @app = Facemock::FbGraph::Application.new(facebook_app_id, @options)
        end

        it 'should set all attributes specified value by argument' do
          expect(@app.identifier).to eq facebook_app_id
          expect(@app.secret).to eq @options[:secret]
          expect(@app.access_token).to eq @options[:access_token]
          expect(Facemock::Database::Application.all.size).to eq @default_record_size
        end
      end
    end
  end

  describe '#fetch' do
    context 'when instance identifier is nil' do
      before { @app = Facemock::FbGraph::Application.new(nil) }
      subject { lambda { @app.fetch } }
      it { is_expected.to raise_error Facemock::FbGraph::InvalidRequest }
    end

    context 'when instance identifier is empty string' do
      before { @app = Facemock::FbGraph::Application.new("") }
      subject { lambda { @app.fetch } }
      it { is_expected.to raise_error Facemock::FbGraph::InvalidRequest }
    end

    context 'when instance identifier is integer' do
      context 'and secret is not specified' do
        before { @app = Facemock::FbGraph::Application.new(facebook_app_id) }
        subject { lambda { @app.fetch } }
        it { is_expected.to raise_error Facemock::FbGraph::InvalidRequest }
      end

      context 'and incorrect secret is specified' do
        before do
          Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
          @app = Facemock::FbGraph::Application.new(facebook_app_id)
          @app.secret = "incorrect_secret"
        end
        subject { lambda { @app.fetch } }
        it { is_expected.to raise_error Facemock::FbGraph::InvalidRequest }
      end

      context 'and the other application secret is specified' do
        before do
          secret = "other_secret"
          app  = Facemock::FbGraph::Application.new(facebook_app_id,     secret: facebook_app_secret)
          app  = Facemock::FbGraph::Application.new(facebook_app_id + 1, secret: secret)
          @app = Facemock::FbGraph::Application.new(facebook_app_id,     secret: secret)
        end
        subject { lambda { @app.fetch } }
        it { is_expected.to raise_error Facemock::FbGraph::InvalidRequest }
      end

      context 'and correct secret is specified' do
        before do
          create_application({ id: facebook_app_id, secret: facebook_app_secret })
          @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
        end

        subject { @app.fetch }
        it { is_expected.to be_kind_of Facemock::FbGraph::Application }

        it 'should not change identifier and secret' do
          identifier = @app.identifier
          secret     = @app.secret
          @app.fetch
          expect(@app.identifier).to eq identifier
          expect(@app.secret).to eq secret
          expect(@app.access_token).to be_nil
        end

        context 'and incorrect access_token is specified' do
          before do
            @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
            @app.access_token = "incorrect_token"
          end
          subject { lambda { @app.fetch } }
          it { is_expected.to raise_error Facemock::FbGraph::InvalidToken }
        end
      end
    end

    context 'when instance identifier is :app' do
      context 'and access token is not specified' do
        before { @app = Facemock::FbGraph::Application.new(:app) }
        subject { lambda { @app.fetch } }
        it { is_expected.to raise_error Facemock::FbGraph::InvalidToken }
      end

      context 'and access token is incorrect' do
        before { @app = Facemock::FbGraph::Application.new(:app, access_token: "incorrect_token") }
        subject { lambda { @app.fetch } }
        it { is_expected.to raise_error Facemock::FbGraph::InvalidToken }
      end

      context 'and access token is correct' do
        before do
          create_application({ id: facebook_app_id, secret: facebook_app_secret})
          app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
          user = app.test_user!
          @access_token = user.access_token
        end

        it 'should set all attributes specified value by argument' do
          app = Facemock::FbGraph::Application.new(:app, access_token: @access_token)
          app.fetch
          expect(app.identifier).to eq facebook_app_id
          expect(app.secret).to eq facebook_app_secret
          expect(app.access_token).to be_nil
        end
      end
    end
  end

  describe '#test_user!' do
    context 'when incorrect access token is specified' do

      it 'should raise error Facemoc::FbGraph::InvalidToken' do
        app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
        app.access_token = "incorrect_token"
        expect(lambda { app.test_user! }).to raise_error Facemock::FbGraph::InvalidToken
      end
    end

    context 'when identifier or secret is incorrect' do
      before { Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret) }

      it 'should raise error Facemoc::FbGraph::InvalidRequest' do
        app = Facemock::FbGraph::Application.new(nil)
        [nil, "", "hoge", facebook_app_id].each do |id|
          app.identifier = id
          [nil, "", "hoge"].each do |secret|
            app.secret = secret
            expect(lambda { app.test_user! }).to raise_error Facemock::FbGraph::InvalidRequest
          end
        end
      end
    end

    context 'when identifier and secret is correct' do
      before do
        create_application({ id: facebook_app_id, secret: facebook_app_secret })
        @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
      end

      it 'should created user' do
        expect(Facemock::FbGraph::Application::User.all).to be_empty
        created_user = @app.test_user!
        finded_user = Facemock::FbGraph::Application::User.find_by_id(created_user.id)
        Facemock::FbGraph::Application::User.column_names.each do |column_name|
          expect(created_user.send(column_name)).to eq finded_user.send(column_name)
        end
      end
    end
  end
  
  describe '#test_users' do
    context 'when identifier is invalid' do
      before { Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret) }

      it 'should raise error Facemock::FbGraph::InvalidRequest' do
        [nil, "", facebook_app_id + 1].each do |id|
          app = Facemock::FbGraph::Application.new(id)
          expect(lambda{ app.test_users }).to raise_error Facemock::FbGraph::InvalidRequest
        end
      end
    end

    context 'when secret is invalid' do
      before { Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret) }

      it 'should raise error Facemock::FbGraph::InvalidRequest' do
        [nil, "", "incorrect_secret"].each do |secret|
          app = Facemock::FbGraph::Application.new(facebook_app_id)
          app.secret = secret
          expect(lambda{ app.test_users }).to raise_error Facemock::FbGraph::InvalidRequest
        end
      end
    end

    context 'when access_token is invalid' do
      it 'should raise error Facemock::FbGraph::InvalidToken' do
        app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
        app.access_token = "incorrect_token"
        expect(lambda{ app.test_users }).to raise_error Facemock::FbGraph::InvalidToken
      end
    end

    context 'when identifier and secret is correct' do
      before do
        create_application({ id: facebook_app_id, secret: facebook_app_secret })
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
end
