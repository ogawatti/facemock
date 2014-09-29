require 'faker'
require 'facemock/database/table'
require 'facemock/user'

module Facemock
  class Application < Database::Table
    TABLE_NAME = :applications
    COLUMN_NAMES = [:id, :secret, :created_at]
    CHILDREN = [ User ]

    # WANT : DBに登録済みの値と重複しないようにする(id, secret)
    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id         = ( opts.id.to_i > 0 ) ? opts.id.to_i : Faker::Number.number(15).to_i
      @secret     = opts.secret || Faker::Lorem.characters(32)
      @created_at = opts.created_at
    end
  end
end
