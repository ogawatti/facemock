require 'facemock/database/table'

module Facemock
  class AuthorizationCode < Database::Table
    TABLE_NAME = :authorization_codes
    COLUMN_NAMES = [:id, :string, :user_id, :created_at]

    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id         = opts.id
      @string     = opts.string || Faker::Lorem.characters
      @user_id    = opts.user_id
      @created_at = opts.created_at
    end
  end
end
