module Facemock
  class Database
    module Migrate
      module Permission
        include Migrate
        extend self

        def create_table
          <<-SQL
            CREATE TABLE permissions (
              id               INTEGER   PRIMARY KEY AUTOINCREMENT,
              name             TEXT      NOT NULL,
              access_token_id  INTEGER   NOT NULL,
              created_at       DATETIME  NOT NULL
            );
          SQL
        end
      end
    end
  end
end
