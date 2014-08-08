require 'facemock/database'
require 'facemock/database/table'
require 'sqlite3'
require 'hashie'

module Facemock
  class Database
    class Permission < Table
      TABLE_NAME = :permissions
      COLUMN_NAMES = [:id, :name, :user_id, :created_at]

      def initialize(options={})
        opts = Hashie::Mash.new(options)
        @id         = opts.id
        @name       = opts.name
        @user_id    = opts.user_id
        @created_at = opts.created_at
      end
    end
  end
end
