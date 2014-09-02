require 'facemock/database/table'
require 'facemock/database/user'

module Facemock
  class Database
    class Application < Table
      TABLE_NAME = :applications
      COLUMN_NAMES = [:id, :secret, :created_at]
      CHILDREN = [ User ]

      # WANT : DBに登録済みの値と重複しないようにする(id, secret)
      def initialize(options={})
        opts = Hashie::Mash.new(options)
        @id         = ( opts.id.to_i > 0 ) ? opts.id.to_i : (0..9).to_a.shuffle[0..15].join.to_i
        @secret     = opts.secret || rand(36**32).to_s(36)
        @created_at = opts.created_at
      end
    end
  end
end
