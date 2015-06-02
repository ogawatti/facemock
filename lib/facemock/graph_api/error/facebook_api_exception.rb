module Facemock
  module GraphAPI
    class Error < StandardError
      class FacebookApiException < Error
        def initialize(message=nil)
          @type = "FacebookApiException"
          super
        end

        class ServiceTemporarilyUnavailable < FacebookApiException
          def initialize(message=nil)
            @message ||= "Service temporarily unavailable"
            @code      = 2
            @status    = 500
            super
          end
        end
      end
    end
  end
end
