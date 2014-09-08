require 'hashie'
require 'facemock/fb_graph/application/user/permission'

module Facemock
  module FbGraph
    class Application
      class User < Facemock::User
        attr_reader :permission_objects

        def initialize(options={})
          opts = Hashie::Mash.new(options)
          if opts.identifier
            opts[:id] = opts.identifier
            opts.delete(:identifier)
          end
          super(opts)

          @permission_objects = User::Permission.find_all_by_user_id(self.id)
          set_permissions(opts.permissions) if opts.permissions
        end

        def permissions
          @permission_objects.inject([]) do |names, perm|
            names << perm.name.to_sym
          end
        end

        def save!
          super
          @permission_objects.each do |permission|
            permission.save!
          end
        end

        def fetch
          @permission_objects = User::Permission.find_all_by_user_id(self.id)
          super
        end

        def destroy
          super
          @permission_objects = []
        end

        def revoke!
          @permission_objects.each do |permission|
            permission.destroy
          end
          @permission_objects = []
        end

        private

        def set_permissions(permissions_string)
          permissions_string.gsub(/\s/, "").split(",").uniq.each do |permission_name|
            unless @permission_objects.find{|perm| perm.name == permission_name}
              @permission_objects << User::Permission.new(
                name: permission_name,
                user_id: self.id
              )
            end
          end
        end
      end
    end
  end
end
