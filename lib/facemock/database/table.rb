require 'facemock/database'
require 'sqlite3'
require 'hashie'

module Facemock
  class Database
    class Table
      TABLE_NAME = :tables
      COLUMN_NAMES = [:id, :created_at]

      def initialize(options={})
        opts = Hashie::Mash.new(options)
        self.id = opts.id
        self.created_at = opts.created_at
      end

      # TODO : 戻り値はtrueのみ。他はraise
      def save!
        if self.id && !(self.class.find_by_id(self.id).nil?)
          update!
        else
          insert!
        end
      end

      # TODO : 戻り値はtrueのみ。他はraise
      def update_attributes!(options)
        # カラムに含まれるかどうかの確認。なければNoMethodError
        options.each_key {|key| self.send(key) }
        update!(options)
      end

      def destroy
        execute "DELETE FROM #{table_name} WHERE ID = #{self.id};"
        fetch
      end

      def fetch
        sql = "SELECT * FROM #{table_name} WHERE ID = #{self.id} LIMIT 1;"
        records = execute sql
        return nil unless record = records.first
        set_attributes_from_record(record)
        self
      end

      def method_missing(name, *args)
        method_name = name.to_s.include?("=") ? name.to_s[0...-1].to_sym : name
        case name
        when :identifier  then return send(:id)
        when :identifier= then return send(:id=, *args)
        else
          if column_names.include?(method_name) && args.size <= 1
            if !name.to_s.include?("=") && args.empty?
              define_column_getter(name)
              return send(name)
            else
              define_column_setter(name)
              return send(name, args.first)
            end
          else
            super
          end
        end
      end

      def self.all
        records = execute "SELECT * FROM #{table_name};"
        records_to_objects(records)
      end

      def self.first
        records = execute "SELECT * FROM #{table_name} LIMIT 1;"
        record_to_object(records.first)
      end

      def self.last
        records = execute "SELECT * FROM #{table_name} ORDER BY ID DESC LIMIT 1 ;"
        record_to_object(records.first)
      end

      def self.where(column)
        column_name = column.keys.first
        value = column.values.first
        column_value = (value.kind_of?(String)) ? "'" + value + "'" : value.to_s

        records = execute "SELECT * FROM #{table_name} WHERE #{column_name} = #{column_value};"
        records_to_objects(records)
      end

      def self.method_missing(name, *args)
        case name
        when /^find_by_(.+)/
          column_name = $1
          super unless column_names.include?(column_name.to_sym)
          raise ArgumentError, "wrong number of arguments (#{args.size} for 1)" unless args.size == 1
          define_find_by_column(column_name)
          send(name, args.first)
        when /^find_all_by_(.+)/
          column_name = $1
          super unless column_names.include?(column_name.to_sym)
          raise ArgumentError, "wrong number of arguments (#{args.size} for 1)" unless args.size == 1
          define_find_all_by_column(column_name)
          send(name, args.first)
        else
          super
        end
      end

      def table_name
        self.class.table_name
      end

      def column_names
        self.class.column_names
      end

      def self.table_name
        self::TABLE_NAME
      end

      def self.column_names
        self::COLUMN_NAMES
      end

      def self.column_type(column_name)
        return nil unless column_names.include?(column_name.to_s.to_sym)
        table_info.send(column_name).type
      end

      def self.table_info
        sql = "PRAGMA TABLE_INFO(#{table_name});"
        records = execute sql
        info = Hashie::Mash.new
        records.each do |record|
          column_info = Hashie::Mash.new(
            { cid:         record[0],
              name:        record[1].to_sym,
              type:        record[2],
              notnull:    (record[3] == 1),
              dflt_value:  record[4],
              pk:         (record[5] == 1) }
          )
          info.send(record[1] + "=", column_info)
        end
        info
      end

      private

      def execute(sql)
        self.class.execute(sql)
      end

      def self.execute(sql)
        database = Facemock::Database.new
        records = database.connection.execute sql
        if records.empty? && sql =~ /^INSERT /
          records = database.connection.execute <<-SQL
            SELECT * FROM #{table_name} WHERE ROWID = last_insert_rowid();
          SQL
        end
        database.disconnect!
        records
      end

      def self.record_to_object(record)
        return nil unless record
        self.new(record_to_hash(record))
      end

      def self.records_to_objects(records)
        records.inject([]) do |objects, record|
          objects << record_to_object(record)
        end
      end

      def record_to_hash(record)
        self.class.record_to_hash(record)
      end

      # 以下の形式のHashが返される
      #   { id: x, ..., created_at: yyyy-mm-dd :hh:mm +xxxx }
      def self.record_to_hash(record)
        hash = Hashie::Mash.new
        column_names.each_with_index do |column_name, index|
          value = (record[index] == "") ? nil : record[index]
          parsed_value = case column_type(column_name)
          when "BOOLEAN" then eval(value)
          when "DATETIME" then Time.parse(value)
          else  value
          end
          hash.send(column_name.to_s + "=", parsed_value)
        end
        hash
      end

      def self.define_find_by_column(column_name)
        self.class_eval <<-EOF
          def self.find_by_#{column_name}(value)
            column_value = case value
            when String then "'" + value + "'"
            when Time   then "'" + value.to_s + "'"
            else value.to_s
            end

            sql  = "SELECT * FROM #{table_name} WHERE #{column_name} = "
            sql += column_value + " LIMIT 1;"
            records = execute sql
            record_to_object(records.first)
          end
        EOF
      end

      def self.define_find_all_by_column(column_name)
        self.class_eval <<-EOF
          def self.find_all_by_#{column_name}(value)
            column_value = case value
            when String then "'" + value + "'"
            when Time   then "'" + value.to_s + "'"
            else value.to_s
            end

            sql  = "SELECT * FROM #{table_name} WHERE #{column_name} = "
            sql += column_value + ";"
            records = execute sql
            records_to_objects(records)
          end
        EOF
      end

      def define_column_getter(name)
        self.class.class_eval <<-EOF
          def #{name}
            self.instance_variable_get(:@#{name})
          end
        EOF
      end

      def define_column_setter(name)
        self.class.class_eval <<-EOF
          def #{name}(value)
            instance_variable_set(:@#{name.to_s.gsub("=", "")}, value)
          end
        EOF
      end

      def insert!
        # idが指定されていない場合の対応
        target_column_names = if self.id
          column_names
        else
          column_names.select{|name| name != :id}
        end

        self.created_at = Time.now
        target_column_values = target_column_names.inject([]) do |ary, column_name|
          ary << "'#{self.send(column_name)}'"
        end
        values  = target_column_values.join(", ")
        columns = target_column_names.join(', ')

        sql = "INSERT INTO #{table_name}(#{columns}) VALUES ( #{values} );"
        records = execute sql
        set_attributes_from_record(records.first)
        self
      end

      def update!(options={})
        # save! から叩かれた場合はここを通る。created_atやその他のcolum値を設定する
        if options.empty?
          column_names.each do |column_name|
            if (value = self.send(column_name)) && column_name != :id
              options[column_name] = value unless options.nil?
            end
          end
        end

        unless options.empty?
          target_key_values = options.inject([]) do |ary, (key, value)|
            ary << (value.kind_of?(Integer) ? "#{key} = #{value}" : "#{key} = '#{value}'")
          end
          sql = "UPDATE #{table_name} SET #{target_key_values.join(', ')} WHERE ID = #{self.id};"
          execute sql
        end
        fetch
      end

      def set_attributes_from_record(record)
        hash = record_to_hash(record)
        column_names.each do |column_name|
          method_name = column_name.to_s + "="
          self.send(method_name, hash.send(column_name))
        end
      end
    end
  end
end
