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
          user = Facemock::User.find_by_access_token(access_token.token)
          @raw_info ||= {
            :id => user.id.to_s,
            :name => user.name,
            #:first_name => 'Joe',
            #:last_name => 'Bloggs',
            #:link => 'http://www.facebook.com/jbloggs',
            #:username => 'jbloggs',
            #:location => { :id => '123456789', :name => 'Palo Alto, California' },
            #:gender => 'male',
            :email => user.email,
            #:timezone => -8,
            #:locale => 'en_US',
            #:verified => true,
            #:updated_time => '2011-11-11T06:21:03+0000'
          }
        end

        protected

        # TODO
        def build_access_token
          code = request.params['code']
          authorization_code = Facemock::AuthorizationCode.find_by_string(code)
          raise_oauth2_error unless authorization_code
          user = Facemock::User.find_by_id(authorization_code.user_id)
          raise_oauth2_error unless user
          app = Facemock::Application.find_by_id(user.application_id)
          raise_oauth2_error unless app

          client = OAuth2::Client.new(app.id, app.secret)
          expires = (Time.now + 60*60*24*80).to_i.to_s  # 80 days
          OAuth2::AccessToken.new(client, user.access_token, {"expires" => expires})
        end

        private

        def raise_oauth2_error
          response = OAuth2::Response.new(Faraday::Response.new)
          response.status = 200
          # ... etc ...
          error = OAuth2::Error.new(response)
          fail error  # fail == raise
        end
      end
    end
  end
end
