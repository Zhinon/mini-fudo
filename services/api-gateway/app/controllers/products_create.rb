require "json"
require "rack"
require "schemas/product_schema"
require "queue_publisher"

PRODUCT_EXCHANGE = "product_exchange"
ROUTING_KEY = "product.created"

module ProductControllers
  class ProductCreateController
    def self.call(env)
      req = Rack::Request.new(env)
      user_id = env["current_user_id"]

      begin
        body = JSON.parse(req.body.read)
      rescue JSON::ParserError
        return [400, json, [{error: "Invalid JSON format"}.to_json]]
      end

      result = Schemas::ProductSchema.call(body)

      unless result.success?
        error_msg = result.errors.to_h.map { |k, v| "#{k}: #{v.join(", ")}" }.join("; ")
        return [422, json, [{error: error_msg}.to_json]]
      end

      name = result[:name]
      QueuePublisher.enqueue(
        exchange_name: PRODUCT_EXCHANGE,
        routing_key: ROUTING_KEY,
        payload: {
          user_id: user_id,
          name: name,
          timestamp: Time.now.to_i
        }
      )

      [202, json, [{status: "Product is being created"}.to_json]]
    end

    def self.json
      {"Content-Type" => "application/json"}
    end
  end
end
