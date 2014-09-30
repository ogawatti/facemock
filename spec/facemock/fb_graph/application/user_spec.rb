require 'spec_helper'

describe Facemock::FbGraph::Application::User do
  let(:db_name)       { ".test" }

  let(:permission1)   { :email }
  let(:permission2)   { :read_stream }
  let(:options)       { { identifier:     100000000000001,
                          name:           "test user",
                          email:          "test@example.com",
                          password:       "testpass",
                          installed:      true,
                          access_token:   "test_token",
                          permissions:    "#{permission1}, #{permission2}",
                          application_id: 1 } }

  before { stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name) }
  after { Facemock::Database.new.drop }

  describe '#new' do
    context 'without options' do
      subject { lambda { Facemock::FbGraph::Application::User.new } }
      it { is_expected.not_to raise_error }

      it 'should be initialized attribute' do
        user = Facemock::FbGraph::Application::User.new

        expect(user.identifier).to         be_kind_of Integer
        expect(user.name).to               be_kind_of String
        expect(user.email).to              be_kind_of String
        expect(user.password).to           be_kind_of String
        expect(user.access_token).to       be_kind_of String
        expect(user.permission_objects).to be_kind_of Array

        expect(user.identifier).to         be >= 100000000000000
        expect(user.name).not_to           be_empty
        expect(user.password).not_to       be_empty
        expect(user.installed).to          be false
        expect(user.access_token).not_to   be_empty
        expect(user.permission_objects).to be_empty
      end
    end

    context 'with all options' do
      it 'should be initialized attribute by options' do
        user = Facemock::FbGraph::Application::User.new(options)
        options.each do |attribute, value|
          unless attribute.eql? :permissions
            expect(user.send(attribute)).to eq value
          end
        end
        
        user.permission_objects.each do |permission_object|
          expect(options[:permissions]).to include permission_object.name
        end
      end
    end
  end

  describe '#permission' do
    context 'when new without permissions option' do
      before do
        opts = options.select {|k, v| k != :permissions}
        @user = Facemock::FbGraph::Application::User.new(opts)
      end

      subject { @user.permissions }
      it { is_expected.to eq [] }
    end

    context 'when new with all options' do
      before do
        @user = Facemock::FbGraph::Application::User.new(options)
      end

      subject { @user.permissions }
      it { is_expected.to include permission1 }
      it { is_expected.to include permission2 }
      it { expect(@user.permissions.size).to eq 2 }
    end
  end

  describe '#save!' do
    context 'when new without permissions option' do
      before do
        opts = options.select {|k, v| k != :permissions}
        @user = Facemock::FbGraph::Application::User.new(opts)
      end

      it 'should not create permission' do
        @user.save!
        expect(@user.permissions).to eq []
        permissions = Facemock::FbGraph::Application::User::Permission.all
        expect(permissions).to be_empty
      end
    end

    context 'when new with permissions option' do
      before { @user = Facemock::FbGraph::Application::User.new(options) }

      it 'should create permission' do
        @user.save!
        expect(@user.permissions).to include permission1
        expect(@user.permissions).to include permission2
        permissions = Facemock::FbGraph::Application::User::Permission.all
        expect(permissions.size).to eq 2
      end
    end
  end

  describe '#fetch' do
    before { @user = Facemock::FbGraph::Application::User.new(options) }

    context 'when user does not save' do
      subject { @user.fetch }
      it { is_expected.to eq nil }
    end

    context 'when user already saved' do
      before do
        @user.save!
      end

      subject { @user.fetch }
      it { is_expected.not_to eq nil }

      describe '.id' do
        subject { @user.fetch.id }
        it { is_expected.to eq @user.id }
      end
    end
  end

  describe '#destroy' do
    context 'when does not have permission' do
      before do
        @user = Facemock::FbGraph::Application::User.create!(options)
      end

      subject { lambda { @user.destroy } }
      it { is_expected.not_to raise_error }

      it 'user does not exist' do
        @user.destroy
        user = Facemock::FbGraph::Application::User.find_by_id(@user.id)
        expect(user).to be_nil
      end
    end

    context 'when have some permissions' do
      before do
        opts = { application_id: 1, permissions: "email, read_stream" }
        @user = Facemock::FbGraph::Application::User.create!(opts)
      end

      subject { lambda { @user.destroy } }
      it { is_expected.not_to raise_error }

      it 'user and permission does not exist' do
        @user.destroy
        expect(Facemock::FbGraph::Application::User.find_by_id(@user.id)).to be_nil
        expect(Facemock::FbGraph::Application::User::Permission.find_all_by_user_id(@user.id)).to be_empty
        expect(@user.permissions).to be_empty
        expect(@user.permission_objects).to be_empty
      end
    end
  end

  describe '#revoke!' do
    context 'when does not have permission' do
      before do
        @user = Facemock::FbGraph::Application::User.create!(options)
      end

      subject { lambda { @user.revoke! } }
      it { is_expected.not_to raise_error }
    end

    context 'when have some permissions' do
      before do
        opts = { application_id: 1, permissions: "email, read_stream" }
        @user = Facemock::FbGraph::Application::User.create!(opts)
      end

      it 'should destroy permissions' do
        @user.revoke!
        expect(Facemock::FbGraph::Application::User::Permission.find_by_user_id(@user.id)).to be_nil
        expect(@user.permissions).to be_empty
      end
    end
  end
end
