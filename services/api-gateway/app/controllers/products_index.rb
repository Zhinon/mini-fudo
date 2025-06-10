require "json"
require "product_client"

module ProductControllers
  class ProductIndexController
    def self.call(env)
      user_id = env["current_user_id"]

      unless user_id
        return [401, json, [{error: "Unauthorized"}.to_json]]
      end

      products = ProductsClient.get_products(user_id)

      unless products
        return [502, json, [{error: "Could not fetch products"}.to_json]]
      end

      [200, json, [products.to_json]]
    end

    def self.json
      {"Content-Type" => "application/json"}
    end
  end
end
