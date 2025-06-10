require "rack"
require "json"
require "rspec"
require "stringio"
require "webmock/rspec"

require "auth_client"
require "controllers/login"
require "schemas/auth_schema"

describe AuthControllers::LoginController do
  let(:headers) do
    {"CONTENT_TYPE" => "application/json"}
  end

  def build_env(body)
    {
      "REQUEST_METHOD" => "POST",
      "rack.input" => StringIO.new(body.to_json)
    }.merge(headers)
  end

  after(:each) do
    WebMock.reset! # Clear WebMock stubs after each example
  end

  context "with valid credentials" do
    let(:valid_username) { "user" }
    let(:valid_password) { "pass" }
    let(:env) { build_env(username: valid_username, password: valid_password) }
    let(:auth_client_response) { {"token" => "Bearer abc123"} }

    before do
      stub_request(:post, "http://auth-service:4000/login")
        .with(body: {username: valid_username, password: valid_password}.to_json)
        .to_return(status: 200, body: auth_client_response.to_json, headers: {"Content-Type" => "application/json"})
    end

    it "returns a 200 OK status and the authentication token" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq(auth_client_response)
    end
  end

  context "with malformed JSON in the request body" do
    let(:env) do
      {
        "REQUEST_METHOD" => "POST",
        "rack.input" => StringIO.new("{invalid_json"),
        "CONTENT_TYPE" => "application/json"
      }
    end

    it "returns a 400 Bad Request status with an error message" do
      status, _, body = described_class.call(env)
      expect(status).to eq(400)
      expect(JSON.parse(body.first)).to eq({"error" => "Invalid JSON format"})
    end
  end

  context "with an invalid request schema (missing fields)" do
    let(:env) { build_env(username: "only_username") }

    it "returns a 422 Unprocessable Entity status with an error message" do
      status, _, body = described_class.call(env)
      expect(status).to eq(422)
      expect(JSON.parse(body.first)).to eq({"error" => "Invalid login data"})
    end
  end

  context "with invalid credentials (AuthClient returns nil)" do
    let(:invalid_username) { "invalid_user" }
    let(:wrong_password) { "wrong" }
    let(:env) { build_env(username: invalid_username, password: wrong_password) }

    before do
      stub_request(:post, "http://auth-service:4000/login")
        .with(body: {username: invalid_username, password: wrong_password}.to_json)
        .to_return(status: 401, body: {error: "Invalid credentials"}.to_json, headers: {"Content-Type" => "application/json"})
    end

    it "returns a 401 Unauthorized status with an error message" do
      status, _, body = described_class.call(env)
      expect(status).to eq(401)
      expect(JSON.parse(body.first)).to eq({"error" => "Invalid credentials"})
    end
  end
end
