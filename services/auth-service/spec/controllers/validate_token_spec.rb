require "utils/jwt_helper"

describe ValidateTokenController do
  let(:json_header) { {"Content-Type" => "application/json"} }

  def env_with_token(token)
    {
      "REQUEST_METHOD" => "GET",
      "HTTP_AUTHORIZATION" => "Bearer #{token}"
    }
  end

  context "when token is valid" do
    it "returns 200 and user_id" do
      payload = {"sub" => 123}
      token = JWT.encode(payload, AppConfig::SECRET_KEY, "HS256")

      allow(JwtHelper).to receive(:decode).with(token).and_return(payload)

      status, headers, body = ValidateTokenController.call(env_with_token(token))

      expect(status).to eq(200)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["status"]).to eq("valid")
      expect(json["user_id"]).to eq(123)
    end
  end

  context "when Authorization header is missing" do
    it "returns 401 with error" do
      env = {"REQUEST_METHOD" => "GET"}

      status, headers, body = ValidateTokenController.call(env)

      expect(status).to eq(401)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Missing Authorization header")
    end
  end

  context "when Authorization header is not Bearer" do
    it "returns 401 with error" do
      env = {
        "REQUEST_METHOD" => "GET",
        "HTTP_AUTHORIZATION" => "Basic abc123"
      }

      status, headers, body = ValidateTokenController.call(env)

      expect(status).to eq(401)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Missing Authorization header")
    end
  end

  context "when token is expired" do
    it "returns 401 with expiration error" do
      token = "expired_token"

      allow(JwtHelper).to receive(:decode).with(token).and_raise(JWT::ExpiredSignature)

      status, headers, body = ValidateTokenController.call(env_with_token(token))

      expect(status).to eq(401)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Token has expired")
    end
  end

  context "when token is invalid" do
    it "returns 401 with decode error" do
      token = "invalid_token"

      allow(JwtHelper).to receive(:decode).with(token).and_raise(JWT::DecodeError)

      status, headers, body = ValidateTokenController.call(env_with_token(token))

      expect(status).to eq(401)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Invalid token")
    end
  end
end
