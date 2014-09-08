require 'facemock/database/table'

module Facemock
  class Permission < Database::Table
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
