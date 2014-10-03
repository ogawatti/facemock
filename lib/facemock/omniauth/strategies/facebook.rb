require 'omniauth-facebook'
require 'oauth2'

module Facemock
  module OmniAuth
    module Strategies
      class Facebook < ::OmniAuth::Strategies::Facebook
        def call!(env)
          if env["PATH_INFO"] == Facemock::Login.path
            Facemock::Login.call(env)
          elsif env["PATH_INFO"] == Facemock::Authentication.path && env["REQUEST_METHOD"] == "POST"
            Facemock::Authentication.call(env)
          else
            super
          end
        end

        def request_phase
          redirect Facemock::Login.path
        end

        # TODO
        def raw_info
          super
        end

        protected

        # TODO
        def build_access_token
          code = request.params['code']
          authorization_code = Facemock::AuthorizationCode.find_by_string(code)
          # oauth2-1.0.0/lib/oauth2/client.rb:L139 参照
          #   raise => fail(Error.new(response))
          raise unless authorization_code
          user = Facemock::User.find_by_id(authorization_code.user_id)
          raise unless user
          app = Facemock::Application.find_by_id(user.application_id)
          raise unless app

          client = OAuth2::Client.new(app.id, app.secret)
          expires = (Time.now + 60*60*24*80).to_i.to_s  # 80 days
          OAuth2::AccessToken.new(client, user.access_token, {"expires" => expires})
        end
      end
    end
  end
end
