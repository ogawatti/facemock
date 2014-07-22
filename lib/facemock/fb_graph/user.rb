require 'facemock/fb_graph/application/user'

module Facemock
  module FbGraph
    module User
      extend self

      def me(access_token)
        Facemock::Config.database
        Application::User.find_by_access_token(access_token)
      end
    end
  end
end
