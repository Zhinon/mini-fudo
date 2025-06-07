require 'bunny'
require 'app_config'

module MessageBroker
    MUTEX = Mutex.new
    class << self
        def connection
            return @connection if @connection

            MUTEX.synchronize do
                @connection ||= Bunny.new(
                    host: AppConfig::RABBITMQ_HOST,
                    port: AppConfig::RABBITMQ_PORT,
                    username: AppConfig::RABBITMQ_USER,
                    password: AppConfig::RABBITMQ_PASS
                ).tap(&:start)
            end
        end

        def channel
            @channel ||= connection.create_channel
        end

        def setup_queue(queue_name:, routing_key:, exchange_name:, dlq: true)
            ch = channel
            exchange = ch.direct(exchange_name, durable: true)
            queue = if dlq
              dlq_name = "#{queue_name}_dlq"
              ch.queue(dlq_name, durable: true)

              ch.queue(queue_name,
                       durable: true,
                       arguments: {
                         'x-dead-letter-exchange'    => '',
                         'x-dead-letter-routing-key' => dlq_name
                       })
            else
              ch.queue(queue_name, durable: true)
            end
            queue.bind(exchange, routing_key: routing_key)
        end
    end
end
