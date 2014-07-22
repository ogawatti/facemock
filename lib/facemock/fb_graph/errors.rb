require 'facemock/fb_graph/user'
require 'facemock/fb_graph/errors'

module Facemock
  module FbGraph
    module Errors
      class Error < StandardError; end
      class InvalidToken < ::FbGraph::InvalidToken; end
    end
  end
end
