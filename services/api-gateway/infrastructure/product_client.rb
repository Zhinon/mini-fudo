require 'net/http'
require 'uri'
require 'json'
require 'app_config'

module ProductsClient
    BASE_URL = 'http://product-service:4000'

    class << self
        def get_products(user_id)
            get("/products?user_id=#{user_id}")
        end

        private

        def get(path)
            uri = URI("#{BASE_URL}#{path}")
            req = Net::HTTP::Get.new(uri)
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
        rescue StandardError => e
            puts "❌ Error contacting product-service: #{e.message}"
            nil
        end
    end
end
