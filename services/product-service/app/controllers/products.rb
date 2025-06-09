require 'json'
require 'db'

class ProductsController
    def self.call(env)
        req = Rack::Request.new(env)

        user_id = req.params['user_id']&.to_i

        unless user_id && user_id > 0
            return [400, { 'Content-Type' => 'application/json' }, [{ error: 'Missing or invalid user_id' }.to_json]]
        end

        products = DB[:products].where(user_id: user_id).all

        [200, { 'Content-Type' => 'application/json' }, [products.to_json]]
    end
end
