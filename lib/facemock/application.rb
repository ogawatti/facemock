require 'facemock/database/table'
require 'facemock/access_token'
require 'facemock/authorization_code'

module Facemock
  class Application < Database::Table
    has_many :access_tokens, :dependent => :destroy
    has_many :authorization_codes, :dependent => :destroy

    # WANT : DBに登録済みの値と重複しないようにする(id, secret)
    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id         = create_id(opts.id)
      @secret     = opts.secret || Faker::Lorem.characters(32)
      @created_at = opts.created_at
    end

    private

    def create_id(id)
      id.to_i > 0 ? id.to_i : Faker::Number.number(15).to_i
    end
  end
end
