require 'webmock'
require 'facemock/graph_api/me'
require 'facemock/graph_api/root'
require 'facemock/graph_api/oauth/access_token'
require 'facemock/graph_api/application/accounts/test-users'
require 'facemock/graph_api/error'

module Facemock
  module GraphAPI
    include WebMock::API
    WebMock.allow_net_connect!
    extend self

    HOSTNAME    = "graph.facebook.com"
    PORT        = 443 
    MIDDLEWARES = [ Me, OAuth::AccessToken ]

    def on
      WebMock.enable!
      stub_request(:any, /#{HOSTNAME}/).to_rack(app)
      @enable = true
      true
    end

    def off
      WebMock.reset!
      WebMock.disable!
      @enable = false
      true
    end

    def on?
      !!@enable
    end

    # Rack Application
    def app 
      app = Proc.new {|env| [ 501, {}, [] ] }
      MIDDLEWARES.inject(app) do |app, klass|
        app = klass.new(app)
      end 
    end 
  end
end
