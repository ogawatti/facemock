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

    def valid?
      [ user_id, application_id ].each do |column|
        return false if column.blank? || !column.instance_of?(Fixnum)
      end
      return false if string.blank? || !string.instance_of?(String)
      return false unless Facemock::User.find_by_id(user_id)
      return false unless Facemock::Application.find_by_id(application_id)
      true
    end
  end
end
