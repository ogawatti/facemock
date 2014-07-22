require 'spec_helper'

describe Facemock::FbGraph::Application::User do
  let(:table_name)    { "users" }

  let(:db_name)       { ".test" }
  let(:adapter)       { "sqlite3" }
  let(:db_directory)  { File.expand_path("../../../../db", __FILE__) }
  let(:db_filepath)   { File.join(db_directory, "#{db_name}.#{adapter}") }
  let(:options)       { { identifier:   100000000000001,
                          name:         "test user",
                          email:        "test@example.com",
                          password:     "testpass",
                          installed:    true,
                          access_token: "test_token",
                          permissions:  "email, read_stream" }  }

  before do
    stub_const("Facemock::Config::Database::DEFAULT_DB_NAME", db_name)
    Facemock::Config.database
  end
  after { Facemock::Config.database.drop }

  it 'should have a rigth class' do
    expect(Facemock::FbGraph::Application::User::Right).to be_truthy
    expect(Facemock::FbGraph::Application::User::Right.ancestors).to include ActiveRecord::Base
  end

  describe '.table_name' do
    subject { Facemock::FbGraph::Application::User.table_name }
    it { is_expected.to eq table_name }
  end

  describe '#new' do
    context 'without options' do
      subject { lambda { Facemock::FbGraph::Application::User.new } }
      it { is_expected.not_to raise_error }

      it 'should be initialized attribute' do
        user = Facemock::FbGraph::Application::User.new

        expect(user.identifier).to        be_kind_of Fixnum
        expect(user.name).to              be_kind_of String
        expect(user.email).to             be_kind_of String
        expect(user.password).to          be_kind_of String
        expect(user.access_token).to      be_kind_of String
        expect(user.permissions).to       be_kind_of Array

        expect(user.identifier).to        be >= 100000000000000
        expect(user.name).not_to          be_empty
        expect(user.password).not_to      be_empty
        expect(user.installed).to         be false
        expect(user.access_token).not_to  be_empty
        expect(user.permissions).to       be_empty
      end
    end

    context 'with all options' do
      it 'should be initialized attribute by options' do
        user = Facemock::FbGraph::Application::User.new(options)
        options.each do |attribute, value|
          if attribute.eql? :permissions
            expect(user.send(attribute)).to include :email
            expect(user.send(attribute)).to include :read_stream
          else
            expect(user.send(attribute)).to eq value
          end
        end
        
        user.rights.each do |right|
          expect(options[:permissions]).to include right.name
        end
      end
    end

    context 'with only name option' do
      before { @options = { name: "test_user" } }

      subject { @user = Facemock::FbGraph::Application::User.new(@options).email }
      it { is_expected.to eq "#{@options[:name]}@example.com" }
    end
  end

  describe '#fetch' do
    before { @user = Facemock::FbGraph::Application::User.new }

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

  describe '#revoke!' do
    before do
      @user = Facemock::FbGraph::Application::User.new
      @user.save!
    end

    it 'should equal destroy' do
      count = Facemock::FbGraph::Application::User.all.count
      @user.revoke!
      expect(Facemock::FbGraph::Application::User.all.count).to eq count - 1
      expect(Facemock::FbGraph::Application::User.find_by_id(@user.id)).to eq nil
    end
  end
end
