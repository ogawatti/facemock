require 'facemock/graph_api/error/oauth_exception'
require 'facemock/graph_api/error/graph_method_exception'
require 'facemock/graph_api/error/facebook_api_exception'
require 'facemock/graph_api/error/response'

module Facemock
  module GraphAPI
    class Error < StandardError
      attr_accessor :type, :code, :status, :message
    
      def response
        @status ||= 500
        header = { "Content-Type"   => "application/json; charset=UTF-8",
                   "Content-Length" => self.to_json.bytesize.to_s }
        res = Response.new(@status, header, self.to_json)
      end

      def to_json
        self.to_hash.to_json
      end

      def to_hash
        @message ||= "Service temporarily unavailable"
        @type    ||= "FacebookApiException"
        @code    ||= 2
        { error: { message: message, type: @type, code: @code } }
      end
    end
  end
end
