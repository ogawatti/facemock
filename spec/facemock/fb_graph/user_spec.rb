require 'spec_helper'

describe Facemock::FbGraph::User do
  let(:facebook_app_id) { "100000000000000" }
  let(:facebook_app_secret) { "test_secret" }
  let(:db_name) { ".test" }
  let(:adapter)       { "sqlite3" }
  let(:table_names)   { [:users, :user_rights] }
  let(:db_directory)  { File.expand_path("../../../../db", __FILE__) }
  let(:db_filepath)   { File.join(db_directory, "#{db_name}.#{adapter}") }

  before do
    stub_const("Facemock::Config::Database::DEFAULT_DB_NAME", db_name)
    Facemock::Config.database
  end
  after  { Facemock::Config.database.drop }

  describe '.me' do
    context 'when access_token is correct' do
      before do
        app = Facemock::FbGraph::Application.new(facebook_app_id, secret: facebook_app_secret)
        @user = app.test_user!
        @access_token = @user.access_token
      end

      it 'can get user' do
        user = Facemock::FbGraph::User.me(@access_token)
        Facemock::FbGraph::Application::User.column_names.each do |column|
          expect(user.send(column)).to eq @user.send(column) unless column == "created_at"
        end
      end
    end

    context 'when access_token is incorrect' do
      subject { Facemock::FbGraph::User.me('incorrect_token') }
      it { is_expected.to eq nil }
    end
  end
end
