require "rack"
require "json"
require "rspec"
require "stringio"
require "webmock/rspec"

require "auth_client"
require "controllers/register"
require "schemas/auth_schema"

describe AuthControllers::RegisterController do
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
    WebMock.reset!
  end

  context "when registration data is valid" do
    let(:valid_username) { "new_user" }
    let(:valid_password) { "secure_pass123" }
    let(:env) { build_env(username: valid_username, password: valid_password) }
    let(:auth_client_response) { {"message" => "User registered successfully"} }

    before do
      stub_request(:post, "http://auth-service:4000/register")
        .with(body: {username: valid_username, password: valid_password}.to_json)
        .to_return(status: 201, body: auth_client_response.to_json, headers: {"Content-Type" => "application/json"})
    end

    it "returns 201 and a success message" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(201)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq(auth_client_response)
    end
  end

  context "when JSON is malformed" do
    let(:env) do
      {
        "REQUEST_METHOD" => "POST",
        "rack.input" => StringIO.new("{invalid_json"),
        "CONTENT_TYPE" => "application/json"
      }
    end

    it "returns 400" do
      status, _, body = described_class.call(env)
      expect(status).to eq(400)
      expect(JSON.parse(body.first)).to eq({"error" => "Invalid JSON format"})
    end
  end

  context "when schema validation fails (missing or invalid fields)" do
    # Case 1: missing fields (e.g., only username, no password)
    let(:env_missing_password) { build_env(username: "incomplete_user") }

    # Case 2: password too short (according to RegisterSchema: min_size?: 6)
    let(:env_short_password) { build_env(username: "user_with_short_pass", password: "abc") }

    it "returns 422 if password is missing" do
      status, _, body = described_class.call(env_missing_password)
      expect(status).to eq(422)
      expect(JSON.parse(body.first)).to eq({"error" => "Invalid registration data"})
    end

    it "returns 422 if password is too short" do
      status, _, body = described_class.call(env_short_password)
      expect(status).to eq(422)
      expect(JSON.parse(body.first)).to eq({"error" => "Invalid registration data"})
    end
  end

  context "when AuthClient.register fails" do
    let(:username) { "failed_user" }
    let(:password) { "some_password" }
    let(:env) { build_env(username: username, password: password) }

    before do
      stub_request(:post, "http://auth-service:4000/register")
        .with(body: {username: username, password: password}.to_json)
        .to_return(status: 422, body: {error: "User already exists"}.to_json, headers: {"Content-Type" => "application/json"})
    end

    it "returns 422 and a registration failure message" do
      status, _, body = described_class.call(env)
      expect(status).to eq(422)
      expect(JSON.parse(body.first)).to eq({"error" => "Registration failed"})
    end
  end
end
