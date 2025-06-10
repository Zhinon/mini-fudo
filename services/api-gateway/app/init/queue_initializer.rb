require "message_broker"

MessageBroker.setup_queue(
  queue_name: "product_queue",
  routing_key: "product.created",
  exchange_name: "product_exchange"
)
