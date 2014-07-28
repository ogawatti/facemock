require 'fb_graph'
require 'facemock/config'
require 'facemock/fb_graph/user'
require 'facemock/fb_graph/errors'
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

      if options[:database_name]
        Facemock::Config.database(options[:database_name])
      else
        Facemock::Config.database
      end
      true
    end

    def off
      if ::FbGraph == Facemock::FbGraph
        Object.send(:remove_const, :FbGraph) if Object.constants.include?(:FbGraph)
        Object.const_set(:FbGraph, ::SourceFbGraph)
        Object.send(:remove_const, :SourceFbGraph) if Object.constants.include?(:FbGraph)
      end
      Facemock::Config.reset_database
      true
    end
  end
end
