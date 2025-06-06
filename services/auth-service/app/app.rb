require 'db'
require 'routes'
require 'middlewares/api_key_validator'


DB = Infrastructure::Database.connect

class App
    def self.call(env)
        stack = ApiKeyValidator.new(Routes)
        stack.call(env)
    end
end
