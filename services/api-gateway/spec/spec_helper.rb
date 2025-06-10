require 'rack/test'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

base_dir = File.expand_path("..", __dir__)
$LOAD_PATH.unshift("#{base_dir}/app")
$LOAD_PATH.unshift("#{base_dir}/config")
$LOAD_PATH.unshift("#{base_dir}/infrastructure")

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
