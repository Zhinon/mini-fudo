require "app_config"

module MiddlewareConfig
  ADMIN_API_PROTECTED_ROUTES = {
    "POST" => ["/register"]
  }
end

class AdminApiKeyValidator
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    method = req.request_method
    path = req.path_info

    if MiddlewareConfig::ADMIN_API_PROTECTED_ROUTES[method]&.include?(path)
      token = req.get_header("HTTP_X_API_KEY")
      return unauthorized unless token == AppConfig::ADMIN_API_KEY
    end

    @app.call(env)
  end

  private

  def unauthorized
    [401, {"Content-Type" => "application/json"}, [{error: "Unauthorized"}.to_json]]
  end
end
