require 'sqlite3'
require 'facemock/database/table'
require 'facemock/database/application'
require 'facemock/database/user'
require 'facemock/database/permission'

module Facemock
  class Database
    ADAPTER = "sqlite3"
    DB_DIRECTORY = File.expand_path("../../../db", __FILE__)
    DEFAULT_DB_NAME = "facemock"
    TABLE_NAMES = [:applications, :users, :permissions]

    attr_reader :name
    attr_reader :connection

    def initialize(name=nil)
      @name = DEFAULT_DB_NAME
      connect
      create_tables
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
      nil
    end

    def clear
      drop_tables
      create_tables
    end

    def create_tables
      TABLE_NAMES.each do |table_name|
        self.send "create_#{table_name}_table" unless table_exists?(table_name)
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
      TABLE_NAMES.each{|table_name| drop_table(table_name) }
      true
    end

    def filepath
      name ||= @name
      File.join(DB_DIRECTORY, "#{@name}.#{ADAPTER}")
    end

    def table_exists?(table_name)
      tables = @connection.execute "select * from sqlite_master"
      tables.each do |table|
        return true if table[1].to_s == table_name.to_s
      end
      false
    end

    private

    def create_applications_table
      @connection.execute <<-SQL
        create table applications (
          id          integer   primary key AUTOINCREMENT,
          secret      text      not null,
          created_at  datetime  not null,
          UNIQUE(secret)
        );
      SQL
    end

    def create_users_table
      @connection.execute <<-SQL
        create table users (
          id              integer  primary key AUTOINCREMENT,
          name            text      not null,
          email           text      not null,
          password        text      not null,
          installed       boolean   not null,
          access_token    text      not null,
          application_id  integer   not null,
          created_at      datetime  not null,
          UNIQUE(access_token)
        );
      SQL
    end

    def create_permissions_table
      @connection.execute <<-SQL
        create table permissions (
          id          integer   primary key AUTOINCREMENT,
          name        text      not null,
          user_id     integer   not null,
          created_at  datetime  not null
        );
      SQL
    end
  end
end
