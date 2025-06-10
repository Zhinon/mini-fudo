require "rack"
require "auth_client"

class AuthMiddleware
  PROTECTED_ROUTES = {
    "POST" => ["/products"],
    "GET" => ["/products"]
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    return @app.call(env) unless protected_route?(req)

    auth_header = req.get_header("HTTP_AUTHORIZATION")
    return unauthorized("Missing or invalid Authorization header") unless auth_header

    user_id = extract_user_id_from_token(auth_header)
    return unauthorized("Invalid token") unless user_id

    env["current_user_id"] = user_id
    @app.call(env)
  end

  private

  def protected_route?(req)
    PROTECTED_ROUTES[req.request_method]&.include?(req.path_info)
  end

  def extract_user_id_from_token(token)
    response = AuthClient.validate_token(token)
    response&.dig("user_id")
  end

  def unauthorized(message)
    [
      401,
      {"Content-Type" => "application/json"},
      [{error: message}.to_json]
    ]
  end
end
