require "rack"
require "json"
require "rspec"
require "stringio"
require "webmock/rspec"

require "product_client"
require "controllers/products_index"

describe ProductControllers::ProductIndexController do
  let(:headers) do
    {"Content-Type" => "application/json"}
  end

  def build_env(user_id = nil)
    {
      "REQUEST_METHOD" => "GET",
      "rack.input" => StringIO.new(""),
      "current_user_id" => user_id
    }.merge(headers)
  end

  after(:each) do
    WebMock.reset!
  end

  context "when user is authorized and products are fetched successfully" do
    let(:user_id) { "authorized_user_123" }
    let(:env) { build_env(user_id) }
    let(:products_from_client) do
      [
        {"id" => 1, "name" => "Product A"},
        {"id" => 2, "name" => "Product B"}
      ]
    end

    before do
      stub_request(:get, "http://product-service:4000/products?user_id=#{user_id}")
        .to_return(status: 200, body: products_from_client.to_json, headers: {"Content-Type" => "application/json"})
    end

    it "returns a 200 OK status with the list of products" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq(products_from_client)
    end
  end

  context "when user is unauthorized (current_user_id is missing)" do
    let(:env) { build_env(nil) } # user_id is nil

    it "returns a 401 Unauthorized status" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(401)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq({"error" => "Unauthorized"})
    end
  end

  context "when ProductsClient fails to fetch products (returns nil)" do
    let(:user_id) { "user_with_client_error" }
    let(:env) { build_env(user_id) }

    before do
      stub_request(:get, "http://product-service:4000/products?user_id=#{user_id}")
        .to_return(status: 500, body: {error: "Internal Server Error"}.to_json, headers: {"Content-Type" => "application/json"})
    end

    it "returns a 502 Bad Gateway status with an error message" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(502)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq({"error" => "Could not fetch products"})
    end
  end
end
