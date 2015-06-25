module Facemock
  class Database
    module Migrate
      module User
        include Migrate
        extend self

        def create_table
          <<-SQL
            CREATE TABLE users (
              id              INTEGER   PRIMARY KEY AUTOINCREMENT,
              name            TEXT      NOT NULL,
              email           TEXT      NOT NULL,
              password        TEXT      NOT NULL,
              role            INTEGER   NOT NULL,
              created_at      DATETIME  NOT NULL,
              UNIQUE(email)
            );
          SQL
        end
      end
    end
  end
end
