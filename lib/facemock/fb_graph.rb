require 'fb_graph'
require 'facemock/config'
require 'facemock/fb_graph/user'
require 'facemock/fb_graph/application'

module Facemock
  module FbGraph
    extend self

    def on(options={})
      if ::FbGraph != Facemock::FbGraph
        Object.const_set(:SourceFbGraph, ::FbGraph)
        Object.send(:remove_const, :FbGraph) if Object.constants.include?(:FbGraph)
        Object.const_set(:FbGraph, Facemock::FbGraph)
      end
      true
    end

    def off
      if ::FbGraph == Facemock::FbGraph
        Object.send(:remove_const, :FbGraph) if Object.constants.include?(:FbGraph)
        Object.const_set(:FbGraph, ::SourceFbGraph)
        Object.send(:remove_const, :SourceFbGraph) if Object.constants.include?(:FbGraph)
      end
      true
    end

    class InvalidToken < ::FbGraph::InvalidToken; end
  end
end
