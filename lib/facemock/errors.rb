module Facemock
  module Errors
    class Error < StandardError; end
    class IncorrectDataFormat < Error; end
    class ColumnTypeNotNull < Error; end
    class InvalidToken < Error; end
  end
end
