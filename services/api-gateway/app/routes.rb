require 'controllers/healthcheck'
require 'controllers/products'
require 'controllers/login'
require 'controllers/register'

module Routes
  def self.call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ['GET', '/healthcheck']
        HealthcheckController.call(env)
    when ['POST', '/login']
        AuthControllers::LoginController.call(env)
    when ['POST', '/register']
        AuthControllers::RegisterController.call(env)
    when ['POST', '/products']
        ProductsController.call(env)
    else
        [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not found"}']]
    end
  end
end
