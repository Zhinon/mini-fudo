require 'json'
require 'message_broker'

module QueuePublisher
    class << self
        def enqueue(exchange_name:, routing_key:, payload:)
            MessageBroker.channel
                         .direct(exchange_name, durable: true)
                         .publish(payload.to_json,
                                  routing_key: routing_key
                                )
        end
    end
end
