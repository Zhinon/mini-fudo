require "controllers/healthcheck"
require "controllers/register"
require "controllers/login"
require "controllers/validate_token"

module Routes
  def self.call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ["GET", "/healthcheck"]
      HealthcheckController.call(env)
    when ["POST", "/register"]
      RegisterController.call(env)
    when ["POST", "/login"]
      LoginController.call(env)
    when ["GET", "/validate_token"]
      ValidateTokenController.call(env)
    else
      [404, {"Content-Type" => "application/json"}, ['{"error":"Not found"}']]
    end
  end
end
