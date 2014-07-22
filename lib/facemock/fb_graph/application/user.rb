require 'active_record'
require 'facemock/fb_graph/application/user/right'
require 'pry'

module Facemock
  module FbGraph
    class Application < ActiveRecord::Base
      class User < ActiveRecord::Base
        self.table_name = "users"
        alias_attribute  :identifier, :id
        has_many :rights, :dependent => :destroy

        def initialize(options={})
          identifier   = options[:identifier]   || ("10000" + (0..9).to_a.shuffle[0..10].join).to_i
          name         = options[:name]         || rand(36**10).to_s(36)
          email        = options[:email]        || name.gsub(" ", "_") + "@example.com"
          password     = options[:password]     || rand(36**10).to_s(36)
          installed    = options[:installed]    || false
          access_token = options[:access_token] || Digest::SHA512.hexdigest(identifier.to_s)

          super(
            :name         => name,
            :email        => email,
            :password     => password,
            :installed    => installed,
            :access_token => access_token
          )
          self.id = identifier
          if options[:permissions] 
            self.permissions = options[:permissions]
          elsif options[:application_id]
            self.application_id = options[:application_id]
          end
        end

        def permissions
          ary = self.rights.inject([]) do |keys, right|
            keys << right.name.to_sym
          end
          ary.uniq
        end

        def fetch
          User.find_by_id(self.id)
        end

        def revoke!
          self.destroy
        end

        private

        def permissions=(permissions_string)
          permissions_string.gsub(/\s/, "").split(",").uniq.each do |permission_name|
            unless self.rights.find{|perm| perm.name == permission_name}
              self.rights.build(name: permission_name)
            end
          end
        end
      end
    end
  end
end
