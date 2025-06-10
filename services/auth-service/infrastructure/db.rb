require "sequel"
require "app_config"

module Infrastructure
  class Database
    def self.connect
      @db ||= Sequel.connect(
        adapter: "postgres",
        host: AppConfig::DB_HOST,
        user: AppConfig::DB_USER,
        password: AppConfig::DB_PASS,
        database: AppConfig::DB_NAME
      )
    end
  end
end
