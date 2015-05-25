require 'spec_helper'
require 'tempfile'

describe Facemock::Config do
  describe '#load_users' do
    let(:db_name)        { ".test" }
    let(:ymlfile) { "testdata.yml" }

    let(:user1) { { identifier: "100000000000001",
                    name:       "test user one",
                    email:      "test_user_one@example.com",
                   password:   "testpass" } }
    let(:user2) { { identifier: "100000000000002",
                    name:       "test user two",
                    email:      "test_user_two@example.com",
                    password:   "testpass" } }
    let(:user3) { { identifier:  100000000000003,
                    name:       "test user three",
                    email:      "test_user_three@example.com",
                    password:   "testpass" } }

    let(:app1_id) { "000000000000001" }
    let(:app1_secret) { "test_secret_one" }
    let(:app1_users) { [user1, user2] }
    let(:app1)  { { app_id: app1_id, app_secret: app1_secret, users: app1_users } }

    let(:app2_id) {  000000000000002  }
    let(:app2_secret) { "test_secret_two" }
    let(:app2_users) { [user3] }
    let(:app2)  { { app_id: app2_id, app_secret: app2_secret, users: app2_users } }

    let(:yaml_load_data) { [ app1, app2 ] }

    context 'without argument' do
      subject { lambda { Facemock::Config.load_users } }
      it { is_expected.to raise_error ArgumentError }
    end

    context 'with yaml file path' do
      before { @database = Facemock::Database.new(db_name) }
      after { @database.drop }

      context 'but file does not exist' do
        subject { lambda { Facemock::Config.load_users("testdata.yml") } }
        it { is_expected.to raise_error Errno::ENOENT }
      end

      def create_temporary_yaml_file(data)
        path = Tempfile.open(ymlfile) do |tempfile|
          tempfile.puts YAML.dump(data)
          tempfile.path
        end
      end

      shared_context 'app and user should not be created', assert: :incorrect_data_format do
        subject { lambda { Facemock::Config.load_users(@path) } }
        it { is_expected.to raise_error Facemock::Errors::IncorrectDataFormat }

        it 'app and user should not be created' do
          begin
            Facemock::Config.load_users(@path)
          rescue => error
            expect(Facemock::Application.all).to be_empty
            expect(Facemock::User.all).to be_empty
          end
        end
      end

      context 'but incorrect format' do
        context 'when load data is not array', assert: :incorrect_data_format do
          before do
            users_data = ""
            @path = create_temporary_yaml_file(users_data)
          end
        end

        context 'when app id does not exist', assert: :incorrect_data_format do
          before do
            users_data = [ { app_secret: app1_secret, users: app1_users } ]
            @path = create_temporary_yaml_file(users_data)
          end
        end

        context 'when app secret does not exist', assert: :incorrect_data_format do
          before do
            users_data = [ { app_id: app1_id, users: app1_users } ]
            @path = create_temporary_yaml_file(users_data)
          end
        end

        context 'when users does not exist', assert: :incorrect_data_format do
          before do
            users_data = [ { app_id: app1_id, app_secret: app1_secret } ]
            @path = create_temporary_yaml_file(users_data)
          end
        end

        context 'when users have only identifier', assert: :incorrect_data_format do
          before do
            users_data = [ { app_id: app1_id, app_secret: app1_secret,
                             users: [ { identifier: "100000000000001" } ] } ]
            @path = create_temporary_yaml_file(users_data)
          end
        end
      end

      context 'yaml is correct format' do
        before { @path = create_temporary_yaml_file(yaml_load_data) }

        subject { lambda { Facemock::Config.load_users(@path) } }
        it { is_expected.not_to raise_error }

        it 'app and user should be created' do
          app_count  = yaml_load_data.size
          user_count = yaml_load_data.inject(0){|count, data| count += data[:users].size }
          Facemock::Config.load_users(@path)
          expect(Facemock::Application.all.count).to eq app_count
          expect(Facemock::User.all.count).to eq user_count
        end

        context 'when already exist specified users' do
          before do
            Facemock::Config.load_users(@path)
          end

          it 'should not raise error' do
            size = Facemock::User.all.size
            expect(size).to eq 3
            path = create_temporary_yaml_file(yaml_load_data)
            Facemock::Config.load_users(path)
            expect(size).to eq 3
          end
        end
      end
    end
  end
end
