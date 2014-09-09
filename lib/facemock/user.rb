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
      @id             = (id.to_i > 0) ? id.to_i : ("10000" + (0..9).to_a.shuffle[0..10].join).to_i
      @name           = opts.name         || rand(36**10).to_s(36)
      @email          = opts.email        || name.gsub(" ", "_") + "@example.com"
      @password       = opts.password     || rand(36**10).to_s(36)
      @installed      = opts.installed    || false
      @access_token   = opts.access_token || rand(36**255).to_s(36)
      app_id = opts.application_id.to_i
      @application_id = (app_id > 0) ? app_id : nil
      @created_at     = opts.created_at
    end
  end
end
