require 'facemock/database/table'
require 'facemock/access_token'
require 'facemock/user'
require 'openssl'

module Facemock
  class Application < Database::Table
    class TestUsers < Array
      attr_reader :application_id
      attr_reader :limit, :after, :before

      def initialize(application_id=nil, options={})
        if application_id
          opts = Hashie::Mash.new(options)
          @application_id = application_id

          # TODO : before, after option
          #  * before/after 両方ある場合、beforeの方が優先される
          access_tokens = Facemock::AccessToken.where(application_id: application_id)
          limit  = validate_limit(opts.limit)  ? opts.limit  : 50
          before = validate_index(opts.before) ? opts.before : nil
          after  = validate_index(opts.after)  ? opts.after  : nil

          if before
            test_user = Facemock::User.find_by_id(before.base62_decode)
            last = access_tokens.find_index{|access_token| access_token.user_id == test_user.id} - 1
            if last < 0
              access_tokens = []
            else
              first = last - limit + 1
              first = 0 if first < 0
              access_tokens = access_tokens[first..last]
            end
          elsif after
            test_user = Facemock::User.find_by_id(after.base62_decode)
            first = access_tokens.find_index{|access_token| access_token.user_id == test_user.id} + 1
            last  = first + limit - 1
            access_tokens = access_tokens[first..last]
          else
            access_tokens = access_tokens[0...limit]
          end

          test_users = access_tokens.inject([]) do |users, access_token|
            user = access_token.user
            users << user if user && user.role == Facemock::User::TEST_ROLE
            users
          end
          @limit  = test_users.empty? ? nil : limit
          @after  = test_users.empty? ? nil : test_users.last.index 
          @before = test_users.empty? ? nil : test_users.first.index 
          super(test_users)
        else
          @limit  = test_users.empty? ? nil : limit
          @after  = test_users.empty? ? nil : test_users.last.index 
          @before = test_users.empty? ? nil : test_users.first.index 
          super([])
        end
      end

      # DOING
      def paging
        return nil if self.empty?
        hash = { cursors: cursors }
        hash[:next] = self.next if self.next
        hash
      end

      def cursors
        self.empty? ? {} : { before: @before, after: @after }
      end

      def next
        return nil if self.empty? || self.count < @limit
        application = Facemock::Application.find_by_id(@application_id)
        params = { access_token: application.server_token.string,
                   type: "test-users",
                   limit: @limit }
        params[:after]  = @after  if @after
        query = params.inject([]){|a, (k,v)| a << "#{k}=#{v}"}.join("&")
        "https://graph.facebook.com/#{@application_id}/accounts" + "?" + query
      end

      def to_data
        data = self.inject([]) do |data, test_user|
          hash = Hashie::Mash.new({ id:        test_user.id,
                                    login_url: login_url(test_user.id) })
          options = { application_id: @application_id, user_id: test_user.id }
          access_token = Facemock::AccessToken.where(options).last
          hash[:access_token] = access_token.string if access_token
          data << hash
        end
        data
      end

      private

      def validate_limit(limit)
        limit && limit > 0 && limit <= 50
      end

      def validate_index(index)
        return false unless index || index.instance_of?(String)
        user = Facemock::User.find_by_id(index.base62_decode)
        return false unless user
        options = { application_id: @application_id, user_id: user.id }
        access_token = Facemock::AccessToken.where(options).last
        !!access_token
      end

      def login_url(user_id)
        File.join(Facemock::Application::LOGIN_BASE_URL, user_id.to_s)
      end
    end
  end
end
