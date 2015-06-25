require 'facemock/graph_api/root'

module Facemock
  module GraphAPI
    class OAuth
      # POST /oauth/access_token
      # grant_type=client_credentials&client_id=120447476832186&client_secret=5vazg9c2uhrbglczbjfawewn0p7miiul
      class AccessToken < Root
        METHOD     = "POST"
        PATH       = "/oauth/access_token"
        GRANT_TYPE = "client_credentials"

        def call(env)
          return super unless called?(env)
          begin
            application  = extract_application(env)
            access_token = application.create_server_token!
            body   = "access_token=#{access_token.string}"
            header = { "Content-Type"   => "text/plain; charset=UTF-8",
                       "Content-Length" => body.bytesize.to_s }
            return [ 200, header, [ body ] ]
          rescue Facemock::GraphAPI::Error => error
            return error.response
          rescue => error
            message = error.message
            error = Facemock::GraphAPI::Error::FacebookApiException::ServiceTemporarilyUnavailable.new
            error.message = message
            return error.response
          end
        end

        private

        def extract_application(env)
          request = Rack::Request.new(env)
          params = Hashie::Mash.new(request.params)

          # applicationの抽出
          if params.blank? || params.grant_type != GRANT_TYPE
            raise Facemock::GraphAPI::Error::OAuthException::MissingRedirectURIParameter.new
          elsif params.client_id.blank?
            raise Facemock::GraphAPI::Error::OAuthException::MissingClientIDParameter.new
          elsif params.client_id.to_i <= 0
            raise Facemock::GraphAPI::Error::OAuthException::AnUnknownErrorHasOccurred.new
          elsif params.client_secret.blank?
            raise Facemock::GraphAPI::Error::OAuthException::ErrorValidatingClientSecret.new
          end
          application = Facemock::Application.find_by_id(params.client_id)

          # applicationの検証
          if application.blank?
            raise Facemock::GraphAPI::Error::OAuthException::ErrorValidatingApplication.new
          elsif application.secret != params.client_secret
            raise Facemock::GraphAPI::Error::OAuthException::ErrorValidatingClientSecret.new
          end
          application
        end
      end
    end
  end
end
