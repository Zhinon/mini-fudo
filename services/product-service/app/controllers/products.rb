require 'json'
require 'db'
require 'serializers/product_serializer'

class ProductsController
    def self.call(env)
        req = Rack::Request.new(env)

        user_id = req.params['user_id']&.to_i

        unless user_id && user_id > 0
            return [
              400,
              { 'Content-Type' => 'application/json' },
              [{ error: 'Missing or invalid user_id' }.to_json]
            ]
          end

        products = DB[:products].where(user_id: user_id).all
        sanitized = products.map { |p| ProductSerializer.call(p) }

        [200, { 'Content-Type' => 'application/json' }, [sanitized.to_json]]
    end
end
