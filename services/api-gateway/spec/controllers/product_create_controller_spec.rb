require "rack"
require "json"
require "rspec"
require "stringio"
require "webmock/rspec"

require "schemas/product_schema"
require "queue_publisher"
require "controllers/products_create"

PRODUCT_EXCHANGE = "product_exchange"
ROUTING_KEY = "product.created"

describe ProductControllers::ProductCreateController do
  let(:headers) do
    {"CONTENT_TYPE" => "application/json"}
  end

  def build_env(body, user_id = "test_user_id")
    {
      "REQUEST_METHOD" => "POST",
      "rack.input" => StringIO.new(body.to_json),
      "current_user_id" => user_id # Simulate user ID from middleware
    }.merge(headers)
  end

  after(:each) do
    WebMock.reset!
  end

  context "with valid product data" do
    let(:product_name) { "New Awesome Product" }
    let(:user_id) { "some_user_uuid" }
    let(:env) { build_env({name: product_name}, user_id) }
    let(:fixed_timestamp) { Time.now.to_i }

    before do
      allow(Time).to receive(:now).and_return(Time.at(fixed_timestamp))

      expect(QueuePublisher).to receive(:enqueue).once.with(
        exchange_name: PRODUCT_EXCHANGE,
        routing_key: ROUTING_KEY,
        payload: {
          user_id: user_id,
          name: product_name,
          timestamp: fixed_timestamp
        }
      )
    end

    it "returns a 202 Accepted status" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(202)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq({"status" => "Product is being created"})
    end
  end

  context "with malformed JSON in the request body" do
    let(:env) do
      {
        "REQUEST_METHOD" => "POST",
        "rack.input" => StringIO.new("{invalid_json"),
        "CONTENT_TYPE" => "application/json",
        "current_user_id" => "some_user_uuid"
      }
    end

    it "returns a 400 Bad Request status with an error message" do
      status, _, body = described_class.call(env)
      expect(status).to eq(400)
      expect(JSON.parse(body.first)).to eq({"error" => "Invalid JSON format"})
    end
  end

  context "when schema validation fails (missing or invalid fields)" do
    let(:env) { build_env({}) } # Missing 'name'

    it "returns a 422 Unprocessable Entity status with an error message" do
      status, _, body = described_class.call(env)
      expect(status).to eq(422)
      expect(JSON.parse(body.first)).to have_key("error")
      expect(JSON.parse(body.first)["error"]).to include("name: is missing")
    end
  end

  context "when QueuePublisher.enqueue fails (e.g., connection issue)" do
    let(:product_name) { "Product that will fail" }
    let(:user_id) { "failing_user" }
    let(:env) { build_env({name: product_name}, user_id) }
    let(:fixed_timestamp) { Time.now.to_i }

    before do
      allow(Time).to receive(:now).and_return(Time.at(fixed_timestamp))
      allow(QueuePublisher).to receive(:enqueue).and_raise(StandardError, "Queue connection error")
    end

    it "lets the QueuePublisher error propagate (no explicit handling in controller)" do
      expect { described_class.call(env) }.to raise_error(StandardError, "Queue connection error")
    end
  end
end
