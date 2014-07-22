require 'active_record'

module Facemock
  module Config
    class Database
      ADAPTER = "sqlite3"
      DB_DIRECTORY = File.expand_path("../../../../db", __FILE__)
      DEFAULT_DB_NAME = "facemock"
      TABLE_NAMES = [:applications, :users, :user_rights]

      attr_reader :name

      def initialize(name=nil)
        @name = (name.nil? || name.empty?) ? DEFAULT_DB_NAME : name
        connect
        create_tables
      end

      def connect
        ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: filepath)
        connection = ActiveRecord::Base.connection unless ActiveRecord::Base.connected?
        ActiveRecord::Migration.verbose = false
        @state = :connected
        connection
      end

      def disconnect!
        ActiveRecord::Base.connection.disconnect!
        @state = :disconnected
      end
      
      def connected?
        @state == :connected
      end

      def drop
        disconnect!
        File.delete(filepath) if File.exist?(filepath)
      end

      def clear
        drop_tables
        create_tables
      end

      def create_tables
        if !File.exist?(filepath) || ActiveRecord::Base.connection.tables.empty?
          TABLE_NAMES.each do |table_name|
            unless ActiveRecord::Base.connection.table_exists? table_name
              self.send "create_#{table_name}_table"
            end
          end
        end
      end

      def drop_tables
        if File.exist?(filepath) && !ActiveRecord::Base.connection.tables.empty?
          TABLE_NAMES.each do |table_name|
            if ActiveRecord::Base.connection.table_exists? table_name
              ActiveRecord::Migration.drop_table table_name
            end
          end
        end
      end

      def filepath
        name ||= @name
        File.join(DB_DIRECTORY, "#{@name}.#{ADAPTER}")
      end

      private

      def create_applications_table
        ActiveRecord::Migration.create_table :applications do |t|
          t.integer :id,     :null => false
          t.string  :secret, :null => false
        end
      end

      def create_users_table
        ActiveRecord::Migration.create_table :users do |t|
          t.integer   :id,             :null => false
          t.string    :name,           :null => false
          t.string    :email,          :null => false
          t.string    :password,       :null => false
          t.boolean   :installed,      :null => false
          t.string    :access_token,   :null => false
          t.integer   :application_id
          t.timestamp :created_at,     :null => false
        end
      end

      def create_user_rights_table
        ActiveRecord::Migration.create_table :user_rights do |t|
          t.string  :name,    :null => false
          t.integer :user_id, :null => false
        end
      end
    end
  end
end
