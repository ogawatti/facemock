module Facemock
  module GraphAPI
    class Error < StandardError
      class Response < Array
        attr_accessor :status, :header, :body

        def initialize(status, header, body)
          @status = status
          @header = header
          @body   = body
          super [ status, header, [ body ] ]
        end
      end
    end
  end
end
