require 'sqlite3'
require 'facemock/database/table'
require 'facemock/database/migrate'

module Facemock
  class Database
    ADAPTER = "sqlite3"
    DB_DIRECTORY = File.expand_path("../../../db", __FILE__)
    DEFAULT_DB_NAME = "facemock"

    attr_reader :connection

    def initialize(name=nil)
      self.class.name = name if name
      connect
      create_tables
      Database::Table.database = self
    end

    def name
      self.class.name
    end

    def self.name
      @name ||= DEFAULT_DB_NAME
    end

    def self.name=(name)
      @name = name
    end

    def connect
      @connection = SQLite3::Database.new filepath
      @state = :connected
      @connection
    end

    def disconnect!
      @connection.close
      @state = :disconnected
      nil
    end
      
    def connected?
      @state == :connected
    end

    def drop
      disconnect!
      File.delete(filepath) if File.exist?(filepath)
      self.class.name = DEFAULT_DB_NAME
      nil
    end

    def clear
      drop_tables
      create_tables
    end

    def self.tables
      Facemock::Database::Migrate.targets.inject([]) do |ary, klass|
        ary << klass.table_name
      end
    end

    def tables
      self.class.tables
    end

    def create_tables
      Facemock::Database::Migrate.targets.each do |klass|
        unless table_exists?(klass.table_name)
          @connection.execute klass.create_table
        end
      end
      true
    end

    def drop_table(table_name)
      return false unless File.exist?(filepath) && table_exists?(table_name)
      @connection.execute "drop table #{table_name};"
      true
    end

    def drop_tables
      return false unless File.exist?(filepath)
      tables.each{|table_name| drop_table(table_name) }
      true
    end

    def filepath
      File.join(DB_DIRECTORY, "#{name}.#{ADAPTER}")
    end

    def table_exists?(table_name)
      tables = @connection.execute "select * from sqlite_master"
      tables.each do |table|
        return true if table[1].to_s == table_name.to_s
      end
      false
    end
  end
end
