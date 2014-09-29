require 'faker'
require 'facemock/database/table'
require 'facemock/permission'
require 'facemock/authorization_code'

module Facemock
  class User < Database::Table
    TABLE_NAME = :users
    COLUMN_NAMES = [:id, :name, :email, :password, :installed, :access_token, :application_id, :created_at]
    CHILDREN = [ Permission, AuthorizationCode ]

    def initialize(options={})
      opts = Hashie::Mash.new(options)
      id = opts.id || opts.identifier
      @id             = (id.to_i > 0) ? id.to_i : ("10000" + Faker::Number.number(10)).to_i
      @name           = opts.name         || create_user_name
      @email          = opts.email        || Faker::Internet.email
      @password       = opts.password     || Faker::Internet.password
      @installed      = opts.installed    || false
      @access_token   = opts.access_token || Faker::Lorem.characters
      app_id = opts.application_id.to_i
      @application_id = (app_id > 0) ? app_id : nil
      @created_at     = opts.created_at
    end

    private

    def create_user_name
      n = Faker::Name.name
      n.include?("'") ? create_user_name : n
    end
  end
end
