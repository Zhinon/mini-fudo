require "app_config"

module MiddlewareConfig
  INTERNAL_API_PROTECTED_ROUTES = {
    "POST" => ["/register", "/login"],
    "GET" => ["/validate_token"]
  }
end

class InternalApiKeyValidator
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    method = req.request_method
    path = req.path_info

    if MiddlewareConfig::INTERNAL_API_PROTECTED_ROUTES[method]&.include?(path)
      token = req.get_header("HTTP_X_INTERNAL_TOKEN")
      return unauthorized unless token == AppConfig::INTERNAL_API_SECRET
    end

    @app.call(env)
  end

  private

  def unauthorized
    [401, {"Content-Type" => "application/json"}, [{error: "Unauthorized"}.to_json]]
  end
end
