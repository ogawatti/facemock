require 'facemock/database'
require 'sqlite3'
require 'hashie'
require 'active_support/core_ext/string/inflections'

module Facemock
  class Database
    class Table
      def initialize(options={})
        opts = Hashie::Mash.new(options)
        column_names.each do |column_name|
          if opts.send(column_name)
            method_name = column_name.to_s + "="
            send(method_name, opts.delete(column_name))
          end
        end
      end

      def save!(options={})
        persisted? ? update!(options) : insert!(options)
      end

      def update_attributes!(options)
        # カラムに含まれるかどうかの確認。なければNoMethodError
        options.each_key {|key| self.send(key) }
        persisted? ? update!(options) : insert!(options)
      end

      def destroy
        raise unless persisted?
        self.class.dependent_destroy.each do |klass_name|
          klass = eval(klass_name.to_s.camelize)
          if self.class.children.include?(klass_name)
            destroy_children(klass)
          elsif self.class.parents.include?(klass_name)
            destroy_parents(klass)
          end
        end

        # 自身のレコード削除
        execute "DELETE FROM #{table_name} WHERE ID = #{self.id};"
        self
      end

      def fetch
        if persisted?
          sql = "SELECT * FROM #{table_name} WHERE ID = #{self.id} LIMIT 1;"
          records = execute sql
          return nil unless record = records.first
          set_attributes_from_record(record)
          self
        end
      end

      def method_missing(name, *args)
        method_name = name.to_s.include?("=") ? name.to_s[0...-1].to_sym : name
        case name
        when :identifier  then return send(:id)
        when :identifier= then return send(:id=, *args)
        end

        if column_getter_method?(name, *args)
          super unless define_column_getter(name)
          return send(name)
        elsif column_setter_method?(name, *args)
          super unless define_column_setter(name)
          return send(name, args.first)
        elsif children_method?(name)
          super unless define_children_method(name)
          return send(name)
        elsif parents_method?(name)
          super unless define_parents_method(name)
          return send(name)
        else
          super
        end
      end

      def self.create!(options={})
        instance = self.new(options)
        instance.save!
        instance
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
        if ((name =~ /^find_by_(.+)/ || name =~ /^find_all_by_(.+)/) && 
          (column_name = $1) && column_names.include?(column_name.to_sym))
          raise ArgumentError, "wrong number of arguments (#{args.size} for 1)" unless args.size == 1
          define_find_method(name, column_name) ? send(name, args.first) : super
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

      def persisted?
        !!(self.id && !(self.class.find_by_id(self.id).nil?))
      end

      def self.table_name
        self.to_s.split("::").last.underscore.pluralize
      end

      def self.column_names
        table_info.inject([]) do |ary, (key, value)|
          ary << key.to_sym
        end
      end

      def self.children
        has_many_target + has_one_target
      end

      def self.parents
        belongs_to_target
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

      def destroy_children(klass)
        column_name = self.class.table_name.to_s.singularize + "_id"
        find_method_name = "find_all_by_#{column_name}"
        find_method_argument = self.id
        objects = klass.send(find_method_name, find_method_argument)
        objects.each{|object| object.destroy }
      end

      def destroy_parents(klass)
        column_name = klass.table_name.to_s.singularize + "_id"
        find_method_name = "find_by_id"
        find_method_argument = eval("self.#{column_name}")
        object = klass.send(find_method_name, find_method_argument)
        object.destroy
      end

      def self.has_many_target
        @has_many_target ||= []
      end

      def self.has_one_target
        @has_one_target ||= []
      end

      def self.belongs_to_target
        @belongs_to_target ||= []
      end

      def column_getter_method?(name, *args)
        column_accessor_method?(name, *args) && getter?(name, *args)
      end

      def column_setter_method?(name, *args)
        column_accessor_method?(name, *args) && !getter?(name, *args)
      end

      def column_accessor_method?(name, *args)
        method_name = name.to_s.include?("=") ? name.to_s[0...-1].to_sym : name
        column_names.include?(method_name) && args.size <= 1
      end

      def getter?(name, *args)
        !name.to_s.include?("=") && args.empty?
      end

      def children_method?(name)
        singularized_name = name.to_s.singularize.to_sym
        self.class.children.include?(singularized_name)
      end

      def parents_method?(name)
        singularized_name = name.to_s.singularize.to_sym
        self.class.parents.include?(singularized_name)
      end

      def has_many_method?(name)
        klass_name = name.to_s.singularize.to_sym
        self.class.has_many_target.include?(klass_name) &&  child_index_method?(name)
      end

      def child_index_method?(name)
        name == name.to_s.pluralize.to_sym
      end

      def has_one_method?(name)
        self.class.has_one_target.include?(name)
      end

      def belongs_to_method?(name)
        self.class.belongs_to_target.include?(name)
      end

      def self.has_many(table_name, options={})
        klass_name = table_name.to_s.singularize.to_sym
        add_has_many_target(klass_name)
        add_dependent_destroy(klass_name) if options[:dependent] == :destroy
      end

      def self.has_one(klass_name, options={})
        add_has_one_target(klass_name)
        add_dependent_destroy(klass_name) if options[:dependent] == :destroy
      end

      def self.belongs_to(klass_name, options={})
        add_belongs_to_target(klass_name)
        add_dependent_destroy(klass_name) if options[:dependent] == :destroy
      end

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

      def self.record_to_object(record, klass=self)
        return nil unless record
        klass.new(record_to_hash(record, klass))
      end

      def self.records_to_objects(records, klass=self)
        records.inject([]) do |objects, record|
          objects << record_to_object(record, klass)
        end
      end

      def record_to_hash(record, klass=self.class)
        self.class.record_to_hash(record, klass)
      end

      # 以下の形式のHashが返される
      #   { id: x, ..., created_at: yyyy-mm-dd :hh:mm +xxxx }
      def self.record_to_hash(record, klass=self)
        hash = Hashie::Mash.new
        klass.column_names.each_with_index do |column_name, index|
          value = (record[index] == "") ? nil : record[index]
          parsed_value = case column_type(column_name)
          when "BOOLEAN"  then value.nil? ? false : eval(value.to_s)
          when "DATETIME" then Time.parse(value)
          else  value
          end
          hash.send(column_name.to_s + "=", parsed_value)
        end
        hash
      end

      def define_and_send_column_accessor_method(name, *args)
        if getter?(name, *args)
          define_column_getter(name)
          return send(name)
        else
          define_column_setter(name)
          return send(name, args.first)
        end
      end

      def define_children_method(name)
        if has_many_method?(name)
          define_has_many_method(name)
        elsif has_one_method?(name)
          define_has_one_method(name)
        else
          false
        end
      end

      def define_parents_method(name)
        if belongs_to_method?(name)
          define_belongs_to_method(name)
        end
      end

      def self.define_find_method(method_name, column_name)
        case method_name
        when /^find_by_(.+)/     then define_find_by_column(column_name)
        when /^find_all_by_(.+)/ then define_find_all_by_column(column_name)
        end
      end

      def self.define_find_by_column(column_name)
        self.class_eval <<-EOF
          def self.find_by_#{column_name}(value)
            return nil if value.nil?

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
        true
      end

      def self.define_find_all_by_column(column_name)
        self.class_eval <<-EOF
          def self.find_all_by_#{column_name}(value)
            return [] if value.nil?

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
        true
      end

      def define_has_many_method(method_name)
        column_name = self.class.table_name.singularize + "_id"
        klass = eval(method_name.to_s.singularize.camelcase)
        self.class.class_eval <<-EOF
          def #{method_name}
            id = self.id
            sql = "SELECT * FROM #{method_name} WHERE #{column_name} = "
            sql += id.to_s + ";"
            records = execute sql
            self.class.records_to_objects(records, #{klass})
          end
        EOF
        true
      end

      def define_has_one_method(method_name)
        column_name = self.class.table_name.singularize + "_id"
        klass = eval(method_name.to_s.camelize)
        self.class.class_eval <<-EOF
          def #{method_name}
            id = self.id
            sql = "SELECT * FROM #{klass.table_name} WHERE #{column_name} = "
            sql += id.to_s + " ORDER BY ID DESC LIMIT 1 ;"
            records = execute sql
            self.class.record_to_object(records.first, #{klass})
          end
        EOF
        true
      end

      def define_belongs_to_method(method_name)
        column_value = eval("self.#{method_name}_id")
        klass = eval(method_name.to_s.camelize)
        self.class.class_eval <<-EOF
          def #{method_name}
            sql = "SELECT * FROM #{klass.table_name} WHERE ID = #{column_value} LIMIT 1 ;"
            records = execute sql
            self.class.record_to_object(records.first, #{klass})
          end
        EOF
        true
      end

      def define_column_getter(name)
        self.class.class_eval <<-EOF
          def #{name}
            self.instance_variable_get(:@#{name})
          end
        EOF
        true
      end

      def define_column_setter(name)
        self.class.class_eval <<-EOF
          def #{name}(value)
            instance_variable_set(:@#{name.to_s.gsub("=", "")}, value)
          end
        EOF
        true
      end

      def self.dependent_destroy
        @dependent_destroy ||= []
      end

      def self.add_child(klass_name)
        @children ? @children << klass_name : @children = [ klass_name ]
        klass_name
      end

      def self.add_has_many_target(klass_name)
        @has_many_target ? @has_many_target << klass_name : @has_many_target = [ klass_name ]
        klass_name
      end

      def self.add_has_one_target(klass_name)
        @has_one_target ? @has_one_target << klass_name : @has_one_target = [ klass_name ]
        klass_name
      end

      def self.add_belongs_to_target(klass_name)
        @belongs_to_target ? @belongs_to_target << klass_name : @belongs_to_target = [ klass_name ]
        klass_name
      end

      def self.add_dependent_destroy(klass_name)
        @dependent_destroy ? @dependent_destroy << klass_name : @dependent_destroy = [ klass_name ]
        klass_name
      end

      # DatabaseへのINSERTが成功してからインスタンスのフィールド値を更新する
      def insert!(options={})
        opts = Hashie::Mash.new(options)
        instance = self.class.new
        column_names.each do |column_name|
          next if column_name == :created_at
          notnull_check(column_name)
          instance.send(column_name.to_s + "=", self.send(column_name))

          if opts.send(column_name)
            instance.send(column_name.to_s + "=", opts.send(column_name))
          end
        end

        target_column_names = if instance.id
          column_names
        else
          column_names.select{|name| name != :id}
        end
        instance.created_at = Time.now
        target_column_values = target_column_names.inject([]) do |ary, column_name|
          ary << "'#{instance.send(column_name)}'"
        end
        values  = target_column_values.join(", ")
        columns = target_column_names.join(', ')

        sql = "INSERT INTO #{table_name}(#{columns}) VALUES ( #{values} );"
        records = execute sql
        set_attributes_from_record(records.first)
        true
      end

      def update!(options={})
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
        true
      end

      def set_attributes_from_record(record)
        hash = record_to_hash(record)
        column_names.each do |column_name|
          method_name = column_name.to_s + "="
          self.send(method_name, hash.send(column_name))
        end
      end

      def column_is_empty?(column_name)
        return true if self.send(column_name).nil?

        return case self.class.column_type(column_name)
        when "TEXT", "DATETIME", "BOOLEAN"
          true if self.send(column_name) == ""
        else
          false
        end
      end

      def self.column_notnull(column_name)
        return nil unless column_names.include?(column_name.to_s.to_sym)
        table_info.send(column_name).notnull
      end

      def notnull_check(column_name)
        if self.class.column_notnull(column_name) && column_is_empty?(column_name)
          raise Facemock::Errors::ColumnTypeNotNull, "#{column_name} is null"
        end
      end
    end
  end
end
