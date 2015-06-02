require 'facemock/graph_api/root'

module Facemock
  module GraphAPI
    # GET /me
    class Me < Root
      METHOD = "GET"
      PATH   = "/me"

      def call(env)
        return super unless called?(env)
        begin
          access_token = extract_access_token(env)
          body   = access_token.user.to_hash.to_json
          header = { "Content-Type"   => "application/json; charset=UTF-8",
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

      def extract_access_token(env)
        request = Rack::Request.new(env)
        params = Hashie::Mash.new(request.params)
        access_token_string = extract_access_token_string(env)

        # Access Tokenの抽出
        if access_token_string.blank?
          raise Facemock::GraphAPI::Error::OAuthException::AccessTokenDoesNotExist.new
        elsif (access_token = Facemock::AccessToken.find_by_string(access_token_string)).nil?
          error = Facemock::GraphAPI::Error::OAuthException::InvalidOAuthAccessToken.new
          error.status = 401 if params.appsecret_proof
          raise error
        elsif !params.appsecret_proof.blank?
          sha256 = OpenSSL::Digest::SHA256.new
          app_secret = access_token.application.secret
          appsecret_proof = OpenSSL::HMAC.hexdigest(sha256, app_secret, access_token.string)
          unless appsecret_proof == params.appsecret_proof
            raise Facemock::GraphAPI::Error::GraphMethodException::InvalidAppSecretProof.new
          end
        end

        # Access Tokenの検証
        if !access_token.valid? || access_token.user.blank?
          raise Facemock::GraphAPI::Error::OAuthException::InvalidAccessToken.new
        end
        access_token
      end

      def extract_access_token_string(env)
        request = Rack::Request.new(env)
        query = Hashie::Mash.new(request.params)
        access_token_string = query.access_token

        if access_token_string.blank?
          unless query.appsecret_proof.blank?
            # access_tokenの抽出
            authorization_header = request.env["Authorization"] || reqeust.env["HTTP_AUTHORIZATION"]
            scheme, access_token_string = authorization_header.split
            raise if scheme != "OAuth"
          end
        end
        access_token_string
      end
    end
  end
end
