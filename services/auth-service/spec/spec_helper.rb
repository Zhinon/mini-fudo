require "rack/test"
require "webmock/rspec"
require "sequel"
require "sqlite3"
require "bcrypt"
require "jwt"
require "json"

ENV["RACK_ENV"] = "test"

base_dir = File.expand_path("..", __dir__)
$LOAD_PATH.unshift("#{base_dir}/app")
$LOAD_PATH.unshift("#{base_dir}/config")
$LOAD_PATH.unshift("#{base_dir}/infrastructure")

WebMock.disable_net_connect!(allow_localhost: true)

DB = Sequel.sqlite

DB.create_table :users do
  primary_key :id
  String :username, null: false, unique: true
  String :password_hash, null: false
  String :salt, null: false
end

require "app_config"
require "controllers/login"
require "controllers/register"
require "controllers/validate_token"

AppConfig.const_set(:SECRET_KEY, "test_secret") unless AppConfig.const_defined?(:SECRET_KEY)

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    DB[:users].truncate
  end

  config.after(:suite) do
    DB.disconnect
  end
end
