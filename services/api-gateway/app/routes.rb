require 'controllers/healthcheck'
require 'controllers/products_create'
require 'controllers/products_index'
require 'controllers/login'
require 'controllers/register'
require 'controllers/static_file'

module Routes
  def self.call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ['GET', '/openapi.yaml']
        StaticControllers::StaticFileController.call(env)
    when ['GET', '/healthcheck']
        HealthcheckController.call(env)
    when ['POST', '/login']
        AuthControllers::LoginController.call(env)
    when ['POST', '/register']
        AuthControllers::RegisterController.call(env)
    when ['POST', '/products']
        ProductControllers::ProductCreateController.call(env)
    when ['GET', '/products']
        ProductControllers::ProductIndexController.call(env)
    else
        [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not found"}']]
    end
  end
end
