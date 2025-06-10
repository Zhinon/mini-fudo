require_relative "../config/boot"

require "json"
require "db"
require "message_broker"

module Workers
  class ProductCreationWorker
    def initialize
      @queue = MessageBroker.get_queue("product_queue")
      @channel = MessageBroker.channel
      @channel.prefetch(1)
    end

    def process(data)
      name = data["name"]
      user_id = data["user_id"]
      sent_at = data["timestamp"].to_i
      now = Time.now.to_i
      diff = now - sent_at

      if diff < 5
        sleep(5 - diff)
      end

      exists = DB[:products].where(name: name, user_id: user_id).first
      if exists
        puts "🟡 Product '#{name}' already exists for user #{user_id}. Skipping insert."
      else
        DB[:products].insert(name: name, user_id: user_id)
        puts "✅ Product inserted successfully"
      end
    end

    def start
      puts "👂 Worker started. Waiting for messages..."

      @queue.subscribe(manual_ack: true, block: true) do |delivery_info, _properties, body|
        data = JSON.parse(body)
        puts "📩 Received: #{data.inspect}"

        process(data)

        @channel.ack(delivery_info.delivery_tag)
      rescue => e
        puts "❌ Error processing message: #{e.message}"
        @channel.reject(delivery_info.delivery_tag, false)
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  Workers::ProductCreationWorker.new.start
end
