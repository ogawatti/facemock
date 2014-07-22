require 'active_record'

module Facemock
  module FbGraph
    class Application < ActiveRecord::Base
      class User < ActiveRecord::Base
        class Right < ActiveRecord::Base
          self.table_name = "user_rights"
          belongs_to :user
        end
      end
    end
  end
end
