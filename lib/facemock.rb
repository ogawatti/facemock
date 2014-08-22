require "facemock/version"
require "facemock/fb_graph"
require "facemock/config"

module Facemock 
  extend self

  def on
    Facemock::FbGraph.on
  end

  def off
    Facemock::FbGraph.off
  end

  def on?
    FbGraph == Facemock::FbGraph
  end
end
