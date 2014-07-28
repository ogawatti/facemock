require 'active_record'
require 'facemock/config'
require 'facemock/fb_graph/application/user'
require 'facemock/fb_graph/application/test_users'

module Facemock
  module FbGraph
    class Application < ActiveRecord::Base
      alias_attribute  :identifier, :id
      has_many :users, :dependent => :destroy

      def initialize(identifier, options={})
        if (identifier == :app && options[:access_token])
          identifier = (0..9).to_a.shuffle[0..15].join
          secret = options[:access_token]
        else
          identifer = identifier.to_s
          secret = options[:secret] || rand(36**32).to_s(36)
        end
        
        super(secret: secret)
        self.identifier = identifier
        save! unless Application.find_by_id_and_secret(identifier, secret)
      end

      def fetch
        self
      end

      def test_user!(options={})
        user = User.new(options)
        user.application_id = self.identifier
        user.save!
        user
      end

      def test_users(options={})
        TestUsers.new(self.identifier, options)
      end
    end
  end
end
