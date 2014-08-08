require 'facemock/fb_graph/application/user'

module Facemock
  module FbGraph
    class Application
      class TestUsers < Array
        DEFAULT_LIMIT = 50
        DEFAULT_AFTER = 0

        def initialize(application_id, options={})
          @limit = limit = (options[:limit] && options[:limit] > 0) ? options[:limit] : DEFAULT_LIMIT
          @after = after = (options[:after] && options[:after] > 0) ? options[:after] : DEFAULT_AFTER
          @application_id = application_id
          st = after
          ed = after + limit - 1
          users = User.find_all_by_application_id(application_id).sort_by{|u| u.created_at}
          users = users.reverse[st..ed] || []
          super(users)
        end

        def collection
          self
        end
        
        def next
          options = { limit: @limit, after: @after + @limit }
          TestUsers.new(@application_id, options)
        end

        def select
          { limit: DEFAULT_LIMIT, after: DEFAULT_AFTER }
        end
      end
    end
  end
end
