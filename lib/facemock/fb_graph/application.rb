require 'hashie'
require 'facemock/config'
require 'facemock/fb_graph/application/user'
require 'facemock/fb_graph/application/test_users'
require 'facemock/database/application'

module Facemock
  module FbGraph
    class Application
      attr_reader :identifier
      attr_reader :secret

      def initialize(identifier, options={})
        opts = Hashie::Mash.new(options)
        if (identifier == :app && opts.access_token)
          identifier = (0..9).to_a.shuffle[0..15].join
          secret = opts.access_token
        else
          secret = opts.secret || rand(36**32).to_s(36)
        end

        @record = Facemock::Database::Application.new({id: identifier, secret: secret})
        @record.save! unless Facemock::Database::Application.find_by_id(identifier)
        @identifier = identifier.to_i
        @secret     = secret
      end

      def fetch
        if @record = Facemock::Database::Application.find_by_id(@identifier)
          @identifier = @record.id
          @secret     = @record.secret
        end
        self
      end

      def test_user!(options={})
        options.merge!({application_id: self.identifier})
        user = User.new(options)
        user.save!
        user
      end

      def test_users(options={})
        TestUsers.new(self.identifier, options)
      end
    end
  end
end
