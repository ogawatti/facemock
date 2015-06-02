module Facemock
  class Database
    module Migrate
      module AuthorizationCode
        include Migrate
        extend self

        def create_table
          <<-SQL
            CREATE TABLE authorization_codes (
              id              INTEGER   PRIMARY KEY AUTOINCREMENT,
              string          TEXT      NOT NULL,
              user_id         INTEGER   NOT NULL,
              application_id  INTEGER   NOT NULL,
              created_at      DATETIME  NOT NULL,
              UNIQUE(string)
            );
          SQL
        end
      end
    end
  end
end
