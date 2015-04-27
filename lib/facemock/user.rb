require 'faker'
require 'facemock/database/table'
require 'facemock/access_token'
require 'facemock/authorization_code'

module Facemock
  class User < Database::Table
    has_many :access_tokens, :dependent => :destroy
    has_many :authorization_code, :dependent => :destroy

    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id         = create_id(opts.identifier || opts.id)
      @name       = opts.name || create_user_name
      @email      = opts.email || Faker::Internet.email
      @password   = opts.password || Faker::Internet.password
      @created_at = opts.created_at
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
