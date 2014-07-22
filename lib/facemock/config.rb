require 'facemock/config/database'

module Facemock
  module Config
    extend self

    def default_database
      Database.new
    end

    def database(name=nil)
      if name.nil? || name.empty?
        @db = default_database
      else
        @db.disconnect! if @db
        @db = Database.new(name)
      end
      @db
    end

    def reset_database
      @db = nil
    end
  end
end
