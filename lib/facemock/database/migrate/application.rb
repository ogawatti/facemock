module Facemock
  class Database
    module Migrate
      module Application
        include Migrate
        extend self

        def create_table
          <<-SQL
            CREATE TABLE applications (
              id          INTEGER   PRIMARY KEY AUTOINCREMENT,
              secret      TEXT      NOT NULL,
              created_at  DATETIME  NOT NULL,
              UNIQUE(secret)
            );
          SQL
        end
      end
    end
  end
end
