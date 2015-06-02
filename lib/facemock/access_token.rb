require 'facemock/database/table'
require 'facemock/permission'

module Facemock
  class AccessToken < Database::Table
    belongs_to :application
    belongs_to :user
    has_many :permissions, :dependent => :destroy

    def initialize(options={})
      opts = Hashie::Mash.new(options)
      @id             = opts.id
      @string         = opts.string || Faker::Lorem.characters
      @user_id        = opts.user_id
      @application_id = opts.application_id
      @created_at     = opts.created_at
    end

    def self.create_server_token!(application_id)
      string = application_id.to_s + "|" + Faker::Lorem.characters[0..26]
      options = { application_id: application_id, string: string }
      self.create!(options)
    end

    def valid?
      return false if application_id.blank? || !application_id.instance_of?(Fixnum)
      return false if string.blank? || !string.instance_of?(String)
      return false unless Facemock::Application.find_by_id(application_id)
      true
    end
  end
end
