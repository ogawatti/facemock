require 'facemock/database/table'

module Facemock
  class AuthorizationCode < Database::Table
    belongs_to :application
    belongs_to :user

    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id             = opts.id
      @string         = opts.string || Faker::Lorem.characters
      @user_id        = opts.user_id
      @application_id = opts.application_id
      @created_at     = opts.created_at
    end
  end
end
