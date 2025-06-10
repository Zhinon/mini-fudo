require "controllers/healthcheck"
require "controllers/products"

module Routes
  def self.call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ["GET", "/healthcheck"]
      HealthcheckController.call(env)
    when ["GET", "/products"]
      ProductsController.call(env)
    else
      [404, {"Content-Type" => "application/json"}, [{error: "Not found"}.to_json]]
    end
  end
end
