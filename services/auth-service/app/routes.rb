require 'controllers/healthcheck'
require 'controllers/register'

module Routes
    def self.call(env)
        req = Rack::Request.new(env)

        case [req.request_method, req.path_info]
        when ['GET', '/healthcheck']
            HealthcheckController.call(env)
        when ['POST', '/register']
            RegisterController.call(env)
        else
            [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not found"}']]
        end
    end
end
