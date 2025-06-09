require_relative 'config/boot'
require 'db'
require 'routes'
require 'middlewares/internal_api_key_validator'

class App
  def self.call(env)
    stack = InternalApiKeyValidator.new(Routes)
    stack.call(env)
  end
end
