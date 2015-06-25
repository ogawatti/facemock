require 'faker'
require 'facemock/database/table'
require 'facemock/access_token'
require 'facemock/authorization_code'
require 'base62'
require 'time'

module Facemock
  class User < Database::Table
    GENERAL_ROLE = 0
    TEST_ROLE    = 1

    has_many :access_tokens, :dependent => :destroy
    has_many :authorization_codes, :dependent => :destroy

    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id         = create_id(opts.identifier || opts.id)
      @name       = opts.name || create_user_name
      @email      = opts.email || Faker::Internet.email
      @password   = opts.password || Faker::Internet.password
      @role       = opts.role || GENERAL_ROLE
      @created_at = opts.created_at
    end

    def to_json
      self.to_hash.to_json
    end

    def to_hash
      { id:           id,
        first_name:   name.split.first,
        gender:       "male",
        last_name:    name.split.last,
        link:         "http://www.facebook.com/#{id}",
        locale:       "ja_JP",
        name:         name,
        timezone:     9,
        updated_time: Time.parse("2014/07/22"),
        verified:     true }
    end

    def test_user?
      self.role == TEST_ROLE
    end

    def index
      self.id.base62_encode
    end

    private

    def create_id(id)
      (id.to_i > 0) ? id.to_i : ("10000" + Faker::Number.number(10)).to_i
    end

    def create_user_name
      n = Faker::Name.name
      n.include?("'") ? create_user_name : n
    end
  end
end
