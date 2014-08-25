require 'spec_helper'

describe Facemock::FbGraph::Application::TestUsers do
  let(:db_name)         { ".test" }

  let(:facebook_app_id) { "100000000000000" }

  let(:default_limit)   { 50 }
  let(:default_after)   { 0 }

  before do
    stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
    @database = Facemock::Database.new
  end
  after { @database.drop }

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
          expect(test_users.count).to eq 1
          test_user = test_users.first
          Facemock::FbGraph::Application::User.column_names.each do |column_name|
            expect(test_user.send(column_name)).to eq @user.send(column_name)
          end
        end
      end
    end

    context 'with application id and options' do
      context 'that limit is 1' do
        context 'when user is exist only two' do
          before do
            2.times do
              Facemock::FbGraph::Application::User.new(application_id: facebook_app_id).save!
            end
            @limit = 1
          end

          it 'should have only one user' do
            test_users = Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, limit: @limit)
            expect(test_users).not_to be_empty
            expect(test_users.count).to eq @limit
            expect(test_users.first).to be_kind_of Facemock::FbGraph::Application::User
          end
        end
      end

      context 'that after is 1' do
        context 'when user is exist only two' do
          before do
            2.times do
              Facemock::FbGraph::Application::User.new(application_id: facebook_app_id).save!
            end
            @after = 1
          end

          it 'should have only one user' do
            test_users = Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, after: @after)
            expect(test_users).not_to be_empty
            expect(test_users.count).to eq 1
            expect(test_users.first).to be_kind_of Facemock::FbGraph::Application::User
          end
        end
      end

      context 'that limit and after are both 1' do
        context 'when user is exist only three' do
          before do
            3.times do
              Facemock::FbGraph::Application::User.new(application_id: facebook_app_id).save!
            end
            @options = { limit: 1, after: 1 }
          end

          it 'should have only one user' do
            test_users = Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, @options)
            expect(test_users).not_to be_empty
            expect(test_users.count).to eq 1
            expect(test_users.first).to be_kind_of Facemock::FbGraph::Application::User
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
      expect(collection.count).to eq @test_users.count
      test_user = collection.first
      Facemock::FbGraph::Application::User.column_names.each do |column_name|
        expect(collection.first.send(column_name)).to eq @test_users.first.send(column_name)
      end
    end
  end

  describe '#next' do
    before do
      @app = Facemock::FbGraph::Application.new(facebook_app_id, secret: "test_secret")
      3.times { @app.test_user! }
    end

    it 'should get next users array' do
      test_users =  Facemock::FbGraph::Application::TestUsers.new(facebook_app_id, limit: 1)
      expect(test_users.first).to be_kind_of Facemock::FbGraph::Application::User
      expect(test_users.next.first).to be_kind_of Facemock::FbGraph::Application::User
      expect(test_users.next.next.first).to be_kind_of Facemock::FbGraph::Application::User
      expect(test_users.next.next.next.first).to be_kind_of NilClass
    end
  end

  describe '#select' do
    before { @expected = { limit: default_limit, after: default_after } }

    subject { Facemock::FbGraph::Application::TestUsers.new(facebook_app_id).select }
    it { is_expected.to eq @expected }
  end
end
