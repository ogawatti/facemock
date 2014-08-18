require 'facemock/database'
require 'facemock/database/table'
require 'sqlite3'
require 'hashie'

module Facemock
  class Database
    class User < Table
      TABLE_NAME = :users
      COLUMN_NAMES = [:id, :name, :email, :password, :installed, :access_token, :application_id, :created_at]

      attr_reader :permission_objects

      def initialize(options={})
        opts = Hashie::Mash.new(options)
        @id             = (opts.id.to_i > 0) ? opts.id.to_i : ("10000" + (0..9).to_a.shuffle[0..10].join).to_i
        #@id             = opts.id.to_i      || ("10000" + (0..9).to_a.shuffle[0..10].join).to_i
        @name           = opts.name         || rand(36**10).to_s(36)
        @email          = opts.email        || name.gsub(" ", "_") + "@example.com"
        @password       = opts.password     || rand(36**10).to_s(36)
        @installed      = opts.installed    || false
        @access_token   = opts.access_token || Digest::SHA512.hexdigest(identifier.to_s)
        app_id = opts.application_id.to_i
        @application_id = (app_id > 0) ? app_id : nil
        @created_at     = opts.created_at
      end
    end
  end
end
