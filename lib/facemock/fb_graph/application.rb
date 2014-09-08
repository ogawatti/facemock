require 'hashie'
require 'facemock/config'
require 'facemock/fb_graph/application/user'
require 'facemock/fb_graph/application/test_users'
require 'facemock/application'

module Facemock
  module FbGraph
    class Application
      attr_accessor :identifier
      attr_accessor :secret
      attr_accessor :access_token  # user access token

      def initialize(identifier, options={})
        opts = Hashie::Mash.new(options)
        @identifier   = identifier
        @secret       = opts.secret
        @access_token = opts.access_token
      end

      def fetch
        @record = if @identifier == :app
          unless validate_access_token
            raise Facemock::FbGraph::InvalidToken.new "Invalid OAuth access token."
          end
          find_by_access_token
        else
          if @access_token && !validate_access_token
            raise Facemock::FbGraph::InvalidToken.new "Invalid OAuth access token."
          elsif !validate_identifier_and_secret
            raise Facemock::FbGraph::InvalidRequest.new "Unsupported get request."
          end
          Facemock::Application.find_by_id(@identifier)
        end

        if @record
          @identifier   = @record.id
          @secret       = @record.secret
          @access_token = nil
        end
        self
      end

      def test_user!(options={})
        validate_and_raise_error
        options.merge!({application_id: self.identifier})
        user = User.create!(options)
      end

      def test_users(options={})
        validate_and_raise_error
        TestUsers.new(self.identifier, options)
      end

      private

      def validate_and_raise_error()
        if @access_token && !validate_access_token
          raise Facemock::FbGraph::InvalidToken.new "Invalid OAuth access token."
        elsif !validate_identifier_and_secret
          raise Facemock::FbGraph::InvalidRequest.new "Unsupported get request."
        end
      end

      def validate_identifier_and_secret
        if validate_identifier && validate_secret
          # WANT : find_by_**_and_**(**, **)の実装
          app_by_id     = Facemock::Application.find_by_id(@identifier)
          app_by_secret = Facemock::Application.find_by_secret(@secret)
          !!(app_by_id && app_by_secret && app_by_id.identifier == app_by_secret.identifier)
        else
          false
        end
      end

      def validate_identifier
        return false if @identifier.nil? || @identifier == ""
        return false unless [Fixnum, String].include?(@identifier.class)
        return false unless Facemock::Application.find_by_id(@identifier)
        true
      end

      def validate_secret
        return false if @secret.nil? || @secret == ""
        return false unless Facemock::Application.find_by_secret(@secret)
        true
      end

      def validate_access_token
        !!(Facemock::User.find_by_access_token(@access_token))
      end

      def find_by_access_token
        if user = Facemock::User.find_by_access_token(@access_token)
          Facemock::Application.find_by_id(user.application_id)
        else
          nil
        end
      end
    end
  end
end
