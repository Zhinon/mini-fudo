require 'json'
require 'bcrypt'
require 'jwt'
require 'app_config'

class LoginController
    def self.call(env)
        req = Rack::Request.new(env)
        params = JSON.parse(req.body.read)

        username = params['username']
        password = params['password']

        return [422, json, [error('Missing username or password')]] unless username && password

        user = DB[:users].where(username: username).first

        return [401, json_header, [error('Invalid credentials')]] unless user

        password_hash = BCrypt::Engine.hash_secret(password, user[:salt])

        unless password_hash == user[:password_hash]
            return [401, json_header, [error('Invalid credentials')]]
        end

        payload = {
            sub: user[:id],
            username: user[:username],
            exp: (Time.now + 86400).to_i  # 1 day
        }

        token = JWT.encode(payload, AppConfig::SECRET_KEY, 'HS256')

        [200, json_header, [{ token: "Bearer #{token}" }.to_json]]
    end

    def self.json_header
        {'Content-Type': 'application/json'}
    end

    def self.error(msg)
        { error: msg }.to_json
    end
end
