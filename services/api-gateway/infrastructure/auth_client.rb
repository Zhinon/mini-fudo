require 'net/http'
require 'uri'
require 'json'
require 'app_config'


module AuthClient
    BASE_URL = 'http://auth-service:4000'

    class << self
        def validate_token(token)
            get('/validate_token', token: token, admin: false)
        end

        def login(username:, password:)
            post('/login', body: { username:, password: })
        end

        def register(username:, password:)
            post('/register', body: { username:, password: }, admin: true)
        end

        private

        def get(path, token: nil, admin: false)
            uri = URI("#{BASE_URL}#{path}")
            req = Net::HTTP::Get.new(uri)
            req['Authorization'] = token if token
            req['X-API-KEY'] = AppConfig::ADMIN_API_KEY if admin
            add_internal_headers!(req)
            perform_request(req, uri)
        end

        def post(path, body:, admin: false)
            uri = URI("#{BASE_URL}#{path}")
            req = Net::HTTP::Post.new(uri)
            req.content_type = 'application/json'
            req.body = body.to_json
            req['X-API-KEY'] = AppConfig::ADMIN_API_KEY if admin
            add_internal_headers!(req)
            perform_request(req, uri)
        end

        def add_internal_headers!(req)
            req['X-Internal-Token'] = AppConfig::INTERNAL_API_SECRET
        end

        def perform_request(request, uri)
            res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
            return nil unless res.code.to_i.between?(200, 299)
            JSON.parse(res.body)
        rescue StandardError
            nil
        end
    end
end
