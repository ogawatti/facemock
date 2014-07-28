require "facemock/version"
require "facemock/fb_graph"
require "facemock/config"

module Facemock 
  extend self

  def on(options={})
    Facemock::FbGraph.on(options)
  end

  def off
    Facemock::FbGraph.off
  end
end
