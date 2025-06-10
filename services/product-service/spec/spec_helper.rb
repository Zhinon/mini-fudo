require "rack/test"
require "webmock/rspec"
require "sequel"
require "sqlite3"
require "json"

ENV["RACK_ENV"] = "test"

base_dir = File.expand_path("..", __dir__)
$LOAD_PATH.unshift("#{base_dir}/app")
$LOAD_PATH.unshift("#{base_dir}/config")
$LOAD_PATH.unshift("#{base_dir}/infrastructure")
$LOAD_PATH.unshift("#{base_dir}/workers")

WebMock.disable_net_connect!(allow_localhost: true)

DB = Sequel.sqlite

DB.create_table :products do
  primary_key :id
  String :name, null: false
  Integer :user_id, null: false
  index :user_id
  unique [:user_id, :name]
end

require "controllers/products"
require "serializers/product_serializer"

unless defined?(AppConfig)
  module AppConfig
    DB_HOST = "localhost"
    DB_USER = "user"
    DB_PASS = "pass"
    DB_NAME = "test"
    RABBITMQ_HOST = "localhost"
    RABBITMQ_PORT = "5672"
    RABBITMQ_USER = "guest"
    RABBITMQ_PASS = "guest"
    INTERNAL_API_SECRET = "test_secret"
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:each) do
    DB[:products].truncate
  end

  config.after(:suite) do
    DB.disconnect
  end
end
