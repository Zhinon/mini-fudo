require "db"
require "routes"
require "middlewares/admin_api_key_validator"
require "middlewares/internal_api_key_validator"

DB = Infrastructure::Database.connect

class App
  def self.call(env)
    stack = InternalApiKeyValidator.new(
                AdminApiKeyValidator.new(
                    Routes
                  )
              )
    stack.call(env)
  end
end
