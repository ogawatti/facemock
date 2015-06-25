require 'facemock/database/table'
require 'facemock/access_token'
require 'facemock/authorization_code'
require 'facemock/application/test_users'
require 'facemock/user'

module Facemock
  class Application < Database::Table
    LOGIN_BASE_URL = "https://developers.facebook.com/checkpoint/test-user-login"
    has_many :access_tokens, :dependent => :destroy
    has_many :authorization_codes, :dependent => :destroy

    # WANT : DBに登録済みの値と重複しないようにする(id, secret)
    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id         = create_id(opts.id)
      @secret     = opts.secret || Faker::Lorem.characters(32)
      @created_at = opts.created_at
    end

    def test_users(options={})
      TestUsers.new(self.id, options)
    end

    def server_token
      find_server_token || create_server_token!
    end

    def find_server_token
      access_tokens = Facemock::AccessToken.where(application_id: self.id)
      return nil if access_tokens.blank?
      access_tokens.select{|at| at.string.include?(self.id.to_s)}.last
    end

    def create_server_token!
      Facemock::AccessToken.create_server_token!(self.id)
    end

    def create_test_user!
      test_user = Facemock::User.create!(role: Facemock::User::TEST_ROLE)
      options = { application_id: self.id, user_id: test_user.id }
      Facemock::AccessToken.create!(options)
      test_user
    end

    private

    def create_id(id)
      id.to_i > 0 ? id.to_i : Faker::Number.number(15).to_i
    end
  end
end
