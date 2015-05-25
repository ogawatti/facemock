require 'rack'
require 'active_support'
require 'active_support/core_ext'
require 'openssl'

module Facemock
  module GraphAPI
    # GET /
    class Root
      METHOD = "GET"
      PATH   = "/"

      def initialize(app)
        @app = app
      end

      def call(env)
        return super unless called?(env)
        begin
          error = Facemock::GraphAPI::Error::GraphMethodException::UnsupportedGetRequest.new
          return error.response
        rescue => e
          #Facemock::GraphAPI::Error::InternalServerError.new(error.message).response
          error = Facemock::GraphAPI::Error::FacebookApiException::ServiceTemporarilyUnavailable.new
          error.message = e.message
        end
      end

      private

      def called?(env)
        request = Rack::Request.new(env)
        request.request_method == self.class::METHOD && request.path == self.class::PATH
      end
    end
  end
end
