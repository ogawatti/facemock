require 'facemock/user'
require 'facemock/permission'

module Facemock
  module FbGraph
    class Application
      class User < Facemock::User
        class Permission < Facemock::Permission
        end
      end
    end
  end
end
