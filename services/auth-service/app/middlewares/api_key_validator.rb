require 'app_config'

NEEDS_API_KEY = {
    'POST' => ['/register'],
    'GET'  => ['/validate_token']
}

class ApiKeyValidator
    def initialize(app)
        @app = app
    end

    def call(env)
        req = Rack::Request.new(env)
        method = req.request_method
        path = req.path

        if NEEDS_API_KEY[method]&.include?(path)
            api_key = req.get_header('HTTP_X_API_KEY')
            expected = AppConfig::ADMIN_API_KEY

            if api_key.nil? || api_key != expected
                return [401, { 'Content-Type' => 'application/json' }, [{error: 'Unauthorized'}.to_json]]
            end
        end

        @app.call(env)
    end
end
