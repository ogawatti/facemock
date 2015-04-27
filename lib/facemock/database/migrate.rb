Dir.glob(File.join(File.expand_path("../migrate", __FILE__), "*")).each do |filepath|
  require filepath
end

module Facemock
  class Database
    module Migrate
      extend self

      def self.targets
        dirpath = File.expand_path("../migrate", __FILE__)
        Dir.glob(File.join(dirpath, "*")).inject([]) do |ary, filepath|
          basename = File.basename(filepath, ".rb")
          klass = eval("Facemock::Database::Migrate::" + basename.camelcase)
          ary << klass
        end
      end

      def table_name
        self.to_s.split("::").last.underscore.pluralize
      end
    end
  end
end
