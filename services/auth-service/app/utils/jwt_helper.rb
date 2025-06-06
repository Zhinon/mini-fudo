require 'jwt'
require 'app_config'

module JwtHelper
    def self.encode(payload, ttl_seconds = 86400)
        payload[:exp] = Time.now.to_i + ttl_seconds
        JWT.encode(payload, AppConfig::SECRET_KEY, 'HS256')
    end

    def self.decode(token)
        decoded = JWT.decode(token, AppConfig::SECRET_KEY, true, algorithm: 'HS256')
        decoded.first
    rescue JWT::DecodeError => e
        nil
    end
end
