require "json"
require "bcrypt"

class RegisterController
  def self.call(env)
    req = Rack::Request.new(env)
    params = JSON.parse(req.body.read)

    username = params["username"]
    password = params["password"]

    return [422, {"Content-Type" => "application/json"}, [{error: "Missing username or password"}.to_json]] unless username && password

    salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, salt)

    begin
      DB[:users].insert(
        username: username,
        password_hash: password_hash,
        salt: salt
      )
      [201, {"Content-Type" => "application/json"}, [{status: "User created"}.to_json]]
    rescue Sequel::UniqueConstraintViolation
      [409, {"Content-Type" => "application/json"}, [{error: "Username already exists"}.to_json]]
    end
  end
end
