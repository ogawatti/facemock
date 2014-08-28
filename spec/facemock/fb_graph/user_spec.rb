require 'spec_helper'

describe Facemock::FbGraph::User do
  include ApplicationCreateHelper

  let(:db_name) { ".test" }

  let(:facebook_app_id) { "100000000000000" }
  let(:facebook_app_secret) { "test_secret" }

  before do
    stub_const("Facemock::Database::DEFAULT_DB_NAME", db_name)
    @database = Facemock::Database.new
  end
  after  { @database.drop }

  describe '.me' do
    context 'when access_token is correct' do
      before do
        create_application({ id: facebook_app_id, secret: "test_secret" })
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
