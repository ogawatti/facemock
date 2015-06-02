module Facemock
  module GraphAPI
    class Error < StandardError
      class GraphMethodException < Error
        def initialize(message=nil)
          @type = "GraphMethodException"
          super
        end

        # 参考
        #  * https://developers.facebook.com/docs/graph-api?locale=ja_JP

        class UnsupportedGetRequest < GraphMethodException
          def initialize(message=nil)
            @message ||= "Unsupported get request. Please read the Graph API documentation at https:\/\/developers.facebook.com\/docs\/graph-api"
            @code      = 100
            @status    = 400
            super
          end
        end

        class InvalidAppSecretProof < GraphMethodException
          def initialize(message=nil)
            @message ||= "Invalid appsecret_proof provided in the API argument"
            @code      = 100
            @status    = 400
            super
          end
        end
      end
    end
  end
end
