require 'yaml'
require 'hashie'
require 'facemock/errors'
require 'facemock/database'

module Facemock
  module Config
    extend self

    def default_database
      Facemock::Database.new
    end

    def database
      default_database
    end

    def reset_database
      db = Facemock::Database.new
      db.disconnect!
      db.drop
    end

    def load_users(ymlfile)
    end
  end
end
