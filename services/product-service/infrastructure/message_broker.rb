require "bunny"
require "app_config"

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

    def get_queue(queue_name)
      channel.queue(queue_name, passive: true)
    end
  end
end
