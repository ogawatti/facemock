module Facemock
  module GraphAPI
    class Error < StandardError
      class OAuthException < Error
        def initialize(message=nil)
          @type = "OAuthException"
          super
        end

        # 参考
        #  * https://developers.facebook.com/docs/graph-api?locale=ja_JP
        # GET /me?access_token=xxx               #=> 400
        # GET /me?appsecret_proof=xxx & header   #=> 401

        class ErrorValidatingClientSecret < OAuthException
          def initialize(message=nil)
            @message ||= "Error validating client secret."
            @code      = 1
            @status    = 400
            super
          end
        end

        class AnUnknownErrorHasOccurred < OAuthException
          def initialize(message=nil)
            @message ||= "An unknown error has occurred."
            @code      = 1
            @status    = 500
            super
          end
        end

        class MissingClientIDParameter < OAuthException
          def initialize(message=nil)
            @message ||= "Missing client_id parameter."
            @code      = 101
            @status    = 400
            super
          end
        end

        class ErrorValidatingApplication < OAuthException
          def initialize(message=nil)
            @message ||= "Error validating application. Cannot get application info due to a system error."
            @code      = 101
            @status    = 400
            super
          end
        end

        class InvalidOAuthAccessToken < OAuthException
          def initialize(message=nil)
            @message ||= "Invalid OAuth access token."
            @code      = 190
            @status    = 400
            super
          end
        end

        class MissingRedirectURIParameter < OAuthException
          def initialize(message=nil)
            @message ||= "Missing redirect_uri parameter."
            @code      = 191
            @status    = 400
            super
          end
        end

        class InvalidAccessToken < OAuthException
          def initialize(message=nil)
            @message ||= "Access token has expired, been revoked, or is otherwise invalid - Handle expired access tokens."
            @code      = 467
            @status    = 400
            super
          end
        end

        class AccessTokenDoesNotExist < OAuthException
          def initialize(message=nil)
            @message  ||= "An active access token must be used to query information about the current user."
            @code      = 2500
            @status    = 400
            super
          end
        end
      end
    end
  end
end
