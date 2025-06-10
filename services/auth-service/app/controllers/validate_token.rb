require "utils/jwt_helper"

class ValidateTokenController
  def self.call(env)
    req = Rack::Request.new(env)
    auth_header = req.get_header("HTTP_AUTHORIZATION")

    return [401, json, [{error: "Missing Authorization header"}.to_json]] unless auth_header&.start_with?("Bearer ")

    token = auth_header.split(" ").last

    begin
      payload = JwtHelper.decode(token)
      [200, json, [{status: "valid", user_id: payload["sub"]}.to_json]]
    rescue JWT::ExpiredSignature
      [401, json, [{error: "Token has expired"}.to_json]]
    rescue JWT::DecodeError
      [401, json, [{error: "Invalid token"}.to_json]]
    end
  end

  def self.json
    {"Content-Type" => "application/json"}
  end
end
