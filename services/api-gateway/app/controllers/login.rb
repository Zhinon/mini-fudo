require "json"
require "rack"
require "auth_client"
require "schemas/auth_schema"

module AuthControllers
  class LoginController
    def self.call(env)
      req = Rack::Request.new(env)
      body = parse_body(req)
      return body unless body.is_a?(Hash)

      result = Schemas::LoginSchema.call(body)
      unless result.success?
        return respond(422, error: "Invalid login data")
      end

      response = AuthClient.login(username: body["username"], password: body["password"])
      return respond(401, error: "Invalid credentials") unless response

      respond(200, response)
    end

    def self.parse_body(req)
      JSON.parse(req.body.read)
    rescue JSON::ParserError
      respond(400, error: "Invalid JSON format")
    end

    def self.respond(status, body)
      [status, {"Content-Type" => "application/json"}, [body.to_json]]
    end
  end
end
