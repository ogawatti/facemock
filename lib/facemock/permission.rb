require 'facemock/database/table'

module Facemock
  class Permission < Database::Table
    belongs_to :access_token

    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id              = opts.id
      @name            = opts.name
      @access_token_id = opts.access_token_id
      @created_at      = opts.created_at
    end
  end
end
