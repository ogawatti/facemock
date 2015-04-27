require 'facemock/database/table'
require 'facemock/permission'

module Facemock
  class AccessToken < Database::Table
    belongs_to :application
    belongs_to :user
    has_many :permissions, :dependent => :destroy

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
