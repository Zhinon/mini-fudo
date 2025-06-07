require 'net/http'
require 'uri'
require 'json'
require 'app_config'

class AuthMiddleware
    PROTECTED_ROUTES = {
        'POST' => ['/products'],
        'GET'  => ['/products']
    }

    def initialize(app)
        @app = app
    end

    def call(env)
        req = Rack::Request.new(env)
        return @app.call(env) unless protected_route?(req)

        auth_header = req.get_header('HTTP_AUTHORIZATION')
        return unauthorized('Missing or invalid Authorization header') unless auth_header

        user_id = validate_token(auth_header)
        return unauthorized('Invalid token') unless user_id

        env['current_user_id'] = user_id
        @app.call(env)
    end

    private

    def protected_route?(req)
        PROTECTED_ROUTES[req.request_method]&.include?(req.path_info)
    end

    def validate_token(token)
        uri = URI('http://auth-service:4000/validate_token')
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = token
        request['X-API-KEY']     = AppConfig::ADMIN_API_KEY

        response = http.request(request)

        return nil unless response.code == '200'

        body = JSON.parse(response.body)
        body['user_id']
    rescue StandardError
        nil
    end

    def unauthorized(message)
        [
            401,
            { 'Content-Type' => 'application/json' },
            [{ error: message }.to_json]
        ]
    end
end
