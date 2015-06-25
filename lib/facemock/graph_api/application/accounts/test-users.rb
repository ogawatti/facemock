require 'facemock/graph_api/root'

module Facemock
  module GraphAPI
    class Application
      class Accounts
        # GET /:application_id/accounts/test-users
        class TestUsers < Root
          METHOD     = "GET"
          PATH       = "/:application_id/accounts/test-users"
          GRANT_TYPE = "client_credentials"
          
          # TODO : limitパラメータ(50~100)対応
          # TODO : 別な方法でのユーザ取得もある...詳細はtmp下のメモ参照
          def call(env)
            return super unless called?(env)
            begin
              access_token = extract_access_token(env)
              application = extract_application(env)
              if access_token.application_id != application.id
                raise Facemock::GraphAPI::Error::GraphMethodException::UnsupportedGetRequest.new
              end
              limit = extract_limit(env)
              # DOING : TestUsers
              #  * paging   #=> { cursors: cursors, next: next }
              #  * cursors  #=> { before: before, after: after }
              #  * next     #=> https://graph.facebook.com/v2.0/:application_id/accounts?access_token=SERVER_ACCESS_TOKEN&type=test-users&limit=LIMIT_PARAMS&after=AFTER_PARAMS"
              #  * limit    #=> 渡されたlimitパラメータ
              #  * before   #=> TestUsersの最初のユーザのxxx
              #  * after    #=> TestUsersの最後のユーザのxxx
              test_users = application.test_users(limit: limit)
              body = { data: test_users.to_data }.to_json
              header = { "Content-Type"   => "application/json; charset=UTF-8",
                         "Content-Length" => body.bytesize.to_s }
              return [ 200, header, [ body ] ]
            rescue Facemock::GraphAPI::Error => error
              return error.response
            rescue => error
              require 'pry'
              binding.pry
              message = error.message
              error = Facemock::GraphAPI::Error::FacebookApiException::ServiceTemporarilyUnavailable.new
              error.message = message
              return error.response
            end
          end

          private

          # Override
          def called?(env)
            request = Rack::Request.new(env)
            return false unless request.request_method == self.class::METHOD
            return false unless request.path.match(/\d+\/accounts\/test-users/)
            true
          end

          def extract_application(env)
            request = Rack::Request.new(env)
            params = Hashie::Mash.new(request.params)

            application_id = extract_application_id(request.path)
            unless application = Facemock::Application.find_by_id(application_id)
              raise Facemock::GraphAPI::Error::GraphMethodException::UnsupportedGetRequest.new
            end

            application
          end

          def extract_application_id(path)
            path.scan(/(\d+)\/accounts\/test-users/).first.first
          end

          def extract_access_token(env)
            request = Rack::Request.new(env)
            if (access_token_string = request.params["access_token"]).blank?
              raise Facemock::GraphAPI::Error::OAuthException::AccessTokenIsRequired.new
            elsif (access_token = Facemock::AccessToken.find_by_string(access_token_string)).blank?
              message = "Invalid OAuth access token signature."
              error = Facemock::GraphAPI::Error::OAuthException::InvalidOAuthAccessToken.new(message)
              raise error
            end
            access_token
          end

          def extract_limit(env)
            request = Rack::Request.new(env)
            limit = request.params["limit"].to_i
            limit = 50 if !(request.params["limit"]) || limit > 50
            if limit < 0
              raise Facemock::GraphAPI::Error::OAuthException::AnUnknownErrorHasOccurred.new
            end
            limit
          end
        end
      end
    end
  end
end
