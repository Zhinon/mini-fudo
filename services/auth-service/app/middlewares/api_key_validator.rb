require 'app_config'


class ApiKeyValidator
    def initialize(app)
        @app = app
    end

    def call(env)
        req = Rack::Request.new(env)

        if req.post? && req.path == '/register'
            api_key = req.get_header('HTTP_X_API_KEY')
            expected = AppConfig::ADMIN_API_KEY

            return [401, { 'Content-Type' => 'application/json' }, ['{"error":"Unauthorized"}']] if api_key.nil? || api_key != expected
        end

        @app.call(env)
    end
end
