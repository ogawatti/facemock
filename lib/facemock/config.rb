require 'yaml'
require 'hashie'
require 'facemock/errors'
require 'facemock/database'
require 'facemock/fb_graph/application'

module Facemock
  module Config
    extend self

    def default_database
      Facemock::Database.new
    end

    def database
      default_database
    end

    def reset_database
      db = Facemock::Database.new
      db.disconnect!
      db.drop
    end

    def load_users(ymlfile)
      load_data = YAML.load_file(ymlfile)
      raise Facemock::Errors::IncorrectDataFormat.new "data is not Array" unless load_data.kind_of?(Array)

      load_data.each do |app_data|
        data = Hashie::Mash.new(app_data)
        app_id     = data.app_id
        app_secret = data.app_secret
        users      = data.users

        # Validate data format
        raise Facemock::Errors::IncorrectDataFormat.new "app id is empty"     unless validate_id(app_id)
        raise Facemock::Errors::IncorrectDataFormat.new "app secret is empty" unless validate_secret(app_secret)
        raise Facemock::Errors::IncorrectDataFormat.new "users format is incorrect" unless validate_users(users)

        # Create application and user record
        Facemock::Database::Application.new({ id: app_id, secret: app_secret }).save!
        app = Facemock::FbGraph::Application.new(app_id, secret: app_secret)
        users.each do |options|
          app.test_user!(options)
        end
      end
    end

    private

    def validate_id(id)
      case id
      when String  then !id.empty?
      when Integer then id >= 0
      else false
      end
    end

    def validate_secret(app_secret)
      case app_secret
      when String then !app_secret.empty?
      else false
      end
    end

    def validate_users(users)
      case users
      when Array
        return false if users.empty?
        users.each {|user| return false unless validate_user(Hashie::Mash.new(user)) }
        true
      else false
      end
    end

    def validate_user(user)
      return false unless validate_id(user.identifier)
      [:name, :password, :name].each do |key|
        value = user.send(key)
        case value
        when String then return false if value.empty?
        else return false
        end
      end
      true
    end
  end
end
