require 'spec_helper'

describe Facemock::FbGraph::Application::TestUsers do
  let(:default_limit)   { 50 }
  let(:default_after)   { 0 }

  let(:db_name)         { ".test" }
  let(:adapter)         { "sqlite3" }
  let(:db_directory)    { File.expand_path("../../../../db", __FILE__) }
  let(:db_filepath)     { File.join(db_directory, "#{db_name}.#{adapter}") }
  let(:facebook_app_id) { "100000000000000" }

  before do
    stub_const("Facemock::Config::Database::DEFAULT_DB_NAME", db_name)
    Facemock::Config.database
  end
  after { Facemock::Config.database.drop }

  describe '::DEFAULT_LIMIT' do
    subject { Facemock::FbGraph::Application::TestUsers::DEFAULT_LIMIT }
    it { is_expected.to eq default_limit }
  end

  describe '::DEFAULT_AFTER' do
    subject { Facemock::FbGraph::Application::TestUsers::DEFAULT_AFTER }
    it { is_expected.to eq default_after }
  end

  describe '#new' do
    context 'without argument' do
      subject { lambda { Facemock::FbGraph::Application::TestUsers.new } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with application id' do
      subject { Facemock::FbGraph::Application::TestUsers.new(facebook_app_id) }
      it { is_expected.to be_kind_of Array }

      context 'when user does not exist' do
        subject { Facemock::FbGraph::Application::TestUsers.new(facebook_app_id) }
        it { is_expected.to be_empty }
      end

      context 'when user exist only one' do
        before do
          @user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
          @user.save!
        end

        it 'should have user' do
          test_users = Facemock::FbGraph::Application::TestUsers.new(facebook_app_id)
          expect(test_users).not_to be_empty
          expect(test_users).to include @user
          expect(test_users.count).to eq 1
        end
      end
    end

    context 'with application id and options' do
      context 'that limit is 1' do
        context 'when user is exist only two' do
          before do
            user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
            user.save!
            @last_created_user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
            @last_created_user.save!
            @limit = 1
          end

          it 'should have only one user' do
            test_users = Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, limit: @limit)
            expect(test_users).not_to be_empty
            expect(test_users.count).to eq 1
            expect(test_users).to include @last_created_user
          end
        end
      end

      context 'that after is 1' do
        context 'when user is exist only two' do
          before do
            @first_created_user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
            @first_created_user.save!
            user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
            user.save!
            @after = 1
          end

          it 'should have only one user' do
            test_users = Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, after: @after)
            expect(test_users).not_to be_empty
            expect(test_users.count).to eq 1
            expect(test_users).to include @first_created_user
          end
        end
      end

      context 'that limit and after are both 1' do
        context 'when user is exist only three' do
          before do
            user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
            user.save!
            @second_created_user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
            @second_created_user.save!
            user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
            user.save!
            @options = { limit: 1, after: 1 }
          end

          it 'should have only one user' do
            test_users = Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, @options)
            expect(test_users).not_to be_empty
            expect(test_users.count).to eq 1
            expect(test_users).to include @second_created_user
          end
        end
      end
    end
  end

  describe '#collection' do
    before do
      user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
      user.save!
      @test_users =  Facemock::FbGraph::Application::TestUsers.new(facebook_app_id)
    end

    it 'should equal self' do
      collection = @test_users.collection
      expect(collection.first).to eq @test_users.first
      expect(collection.count).to eq @test_users.count
    end
  end

  describe '#next' do
    before do
      @first_created_user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
      @first_created_user.save!
      @second_created_user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
      @second_created_user.save!
      @last_created_user = Facemock::FbGraph::Application::User.new(application_id: facebook_app_id)
      @last_created_user.save!
    end

    it 'should get next users array' do
      test_users =  Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, limit: 1)
      expect(test_users.first).to eq @last_created_user
      expect(test_users.next.first).to eq @second_created_user
      expect(test_users.next.next.first).to eq @first_created_user
    end
  end

  describe '#select' do
    before { @expected = { limit: default_limit, after: default_after } }

    subject { Facemock::FbGraph::Application::TestUsers.new(facebook_app_id).select }
    it { is_expected.to eq @expected }
  end
end
