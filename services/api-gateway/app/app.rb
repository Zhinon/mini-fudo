require 'routes'
require 'middlewares/auth_middleware'

class App
    def self.call(env)
      AuthMiddleware.new(Routes).call(env)
    end
end
