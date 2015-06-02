module Facemock
  class Database
    module Migrate
      module AccessToken
        include Migrate
        extend self

        def create_table
          <<-SQL
            CREATE TABLE access_tokens (
              id              INTEGER   PRIMARY KEY AUTOINCREMENT,
              string          TEST      NOT NULL,
              user_id         INTEGER,
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
