require 'spec_helper'

describe Facemock::Application::TestUsers do
  let(:db_name)      { ".test" }
  let(:login_base_url) { "https://developers.facebook.com/checkpoint/test-user-login" }

  before { @database = Facemock::Database.new(db_name) }
  after { @database.drop }

  # DOING : インスタンス変数 after/before/limit
  describe '#initialize' do
    context 'without argument' do
      subject { Facemock::Application::TestUsers.new }
      it { is_expected.to be_empty }
    end

    context 'with application_id' do
      before do
        @application = Facemock::Application.create!
        @test_user_one = @application.create_test_user!
        @test_user_two = @application.create_test_user!
        user = Facemock::User.create!
        opts = { application_id: @application.id, user_id: user.id }
        access_token = Facemock::AccessToken.create!(opts)
      end
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id, options) }

      shared_examples 'Include Created Test User' do
        it 'should include create test user' do
          expect(test_users.count).to    eq test_users_count
          expect(test_users.first.id).to eq test_users_first_id
          expect(test_users.last.id).to  eq test_users_last_id
          expect(test_users.limit).to    eq test_users_limit
          expect(test_users.before).to   eq test_users_before
          expect(test_users.after).to    eq test_users_after
        end
      end

      shared_examples 'Not Include Created Test User' do
        it 'should not include create test user' do
          expect(test_users.count).to  eq 0
          expect(test_users.limit).to  be_nil
          expect(test_users.before).to be_nil
          expect(test_users.after).to  be_nil
        end
      end

      context 'without limit and before, after options' do
        let(:options) { {} }
        let(:test_users_count)    { 2 }
        let(:test_users_first_id) { @test_user_one.id }
        let(:test_users_last_id)  { @test_user_two.id }
        let(:test_users_limit)    { 50 }
        let(:test_users_before)   { @test_user_one.index }
        let(:test_users_after)    { @test_user_two.index }
        it_behaves_like 'Include Created Test User'
      end

      context 'and limit 1 options' do
        let(:options) { { limit: 1 } }
        let(:test_users_count)    { 1 }
        let(:test_users_first_id) { @test_user_one.id }
        let(:test_users_last_id)  { @test_user_one.id }
        let(:test_users_limit)    { 1 }
        let(:test_users_before)   { @test_user_one.index }
        let(:test_users_after)    { @test_user_one.index }
        it_behaves_like 'Include Created Test User'
      end

      context 'and limit 1, before (index) test user one options' do
        let(:options) { { limit: 1, before: @test_user_one.index } }
        it_behaves_like 'Not Include Created Test User'
      end

      context 'and limit 1, before (index) test user two options' do
        let(:options) { { limit: 1, before: @test_user_two.index } }
        let(:test_users_count)    { 1 }
        let(:test_users_first_id) { @test_user_one.id }
        let(:test_users_last_id)  { @test_user_one.id }
        let(:test_users_limit)    { 1 }
        let(:test_users_before)   { @test_user_one.index }
        let(:test_users_after)    { @test_user_one.index }
        it_behaves_like 'Include Created Test User'
      end

      context 'and limit 1, after (index) test user one options' do
        let(:options) { { limit: 1, after: @test_user_one.index } }
        let(:test_users_count)    { 1 }
        let(:test_users_first_id) { @test_user_two.id }
        let(:test_users_last_id)  { @test_user_two.id }
        let(:test_users_limit)    { 1 }
        let(:test_users_before)   { @test_user_two.index }
        let(:test_users_after)    { @test_user_two.index }
        it_behaves_like 'Include Created Test User'
      end

      context 'and limit 1, after (index) test user two options' do
        let(:options) { { limit: 1, before: @test_user_one.index } }
        it_behaves_like 'Not Include Created Test User'
      end

      context 'and limit 1, after (index) test user one, before (index) test user two options' do
        let(:options) { { limit: 1, before: @test_user_two.index, after: @test_user_one.index } }
        let(:test_users_count)    { 1 }
        let(:test_users_first_id) { @test_user_one.id }
        let(:test_users_last_id)  { @test_user_one.id }
        let(:test_users_limit)    { 1 }
        let(:test_users_before)   { @test_user_one.index }
        let(:test_users_after)    { @test_user_one.index }
        it_behaves_like 'Include Created Test User'
      end
    end
  end

  describe '#cursors' do
    before { @application = Facemock::Application.create! }
    subject { test_users.cursors }

    context 'when empty' do
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id) }
      let(:cursors) { {} }
      it { is_expected.to eq cursors }
    end

    context 'when include test user' do
      before { @application.create_test_user! }
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id) }
      let(:cursors) { { before: test_users.before, after: test_users.after } }
      it { is_expected.to eq cursors }
    end
  end

  describe 'next' do
    before { @application = Facemock::Application.create! }
    subject { test_users.next }

    context 'when empty' do
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id) }
      let(:test_users_next) { nil }
      it { is_expected.to eq test_users_next }
    end

    context 'when include all test user' do
      before { @application.create_test_user! }
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id) }
      let(:test_users_next) { nil }
      it { is_expected.to eq test_users_next }
    end

    context 'when include first test user' do
      before do
        2.times { @application.create_test_user! }
        @access_token = @application.create_server_token!
      end
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id, { limit: limit }) }
      let(:test_users_next) { "https://graph.facebook.com/#{@application.id}/accounts?#{query}" }
      let(:limit) { 1 }
      let(:query) { params.inject([]){|a, (k,v)| a << "#{k}=#{v}"}.join("&") }
      let(:params) { { access_token: @access_token.string,
                       type: "test-users",
                       limit: limit,
                       after: test_users.last.index } }
      it { is_expected.to eq test_users_next }
    end

    context 'when include last test user' do
      before do
        2.times { @application.create_test_user! }
        @access_token = @application.create_server_token!
      end
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id) }
      let(:test_users_next) { nil }
      it { is_expected.to eq test_users_next }
    end
  end

  # DOING
  describe '#paging' do
    before { @application = Facemock::Application.create! }
    subject { test_users.paging }

    context 'when empty' do
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id) }
      let(:paging) { nil }
      it { is_expected.to eq paging }
    end

    context 'when include all test user' do
      before { 2.times { @application.create_test_user! } }
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id) }
      let(:paging) { { cursors: test_users.cursors } }
      it { is_expected.to eq paging }
    end

    context 'when include first test user' do
      before { 2.times { @application.create_test_user! } }
      let(:test_users) { Facemock::Application::TestUsers.new(@application.id, { limit: 1 }) }
      let(:paging) { { cursors: test_users.cursors, next: test_users.next } }
      it { is_expected.to eq paging }
    end

    # DOING
    context 'when include last test user' do
    end
  end

  describe '#to_data' do
    context 'when empty' do
      let(:test_users) { Facemock::Application::TestUsers.new }
      subject { test_users.to_data }
      it { is_expected.to be_empty }
      it { is_expected.to be_instance_of Array }
    end

    context 'when have some test users' do
      before do
        @application = Facemock::Application.create!
        2.times do
          test_user = Facemock::User.create!(role: Facemock::User::TEST_ROLE)
          options = { application_id: @application.id, user_id: test_user.id }
          Facemock::AccessToken.create!(options)
        end
        @test_users = Facemock::Application::TestUsers.new(@application.id)
      end

      it "should include test users id and login url, access token" do
        data = @test_users.to_data
        expect(data).to be_instance_of Array
        expect(data.size).to eq 2

        (0..1).each do |i|
          user_data = data[i]
          test_user  = @test_users[i]
          expect(user_data).to be_instance_of Hashie::Mash
          expect(user_data.id).to eq test_user.id
          login_url = File.join(login_base_url, test_user.id.to_s)
          expect(user_data.login_url).to eq login_url
          options = { application_id: @application.id,
                      user_id: test_user.id }
          access_token = Facemock::AccessToken.where(options).last
          expect(user_data.access_token).to eq access_token.string
         end
       end
     end
  end

  describe '#after' do
    let(:application) { Facemock::Application.create! }
    subject { application.test_users.after }
    it { is_expected.to be_nil }

    context 'when test user exist' do
      before { 3.times { application.create_test_user! } }
      it { is_expected.to eq application.test_users.last.index }
    end
  end

  describe '#before' do
    let(:application) { Facemock::Application.create! }
    subject { application.test_users.before }
    it { is_expected.to be_nil }

    context 'when test user exist' do
      before { 3.times { application.create_test_user! } }
      it { is_expected.to eq application.test_users.first.index }
    end
  end
end
