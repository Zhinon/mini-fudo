describe LoginController do
  let(:json_header) { {"Content-Type" => "application/json"} }
  let(:username) { "testuser" }
  let(:password) { "secure123" }

  def build_env(body_hash)
    {
      "REQUEST_METHOD" => "POST",
      "rack.input" => StringIO.new(body_hash.to_json)
    }
  end

  context "when credentials are valid" do
    it "returns 200 and a Bearer token" do
      salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(password, salt)

      DB[:users].insert(username: username, password_hash: password_hash, salt: salt)

      env = build_env({username: username, password: password})
      status, headers, body = LoginController.call(env)

      expect(status).to eq(200)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["token"]).to start_with("Bearer ")
    end
  end

  context "when username does not exist" do
    it "returns 401 and error message" do
      env = build_env({username: "nonexistent", password: "any"})
      status, headers, body = LoginController.call(env)

      expect(status).to eq(401)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Invalid credentials")
    end
  end

  context "when password is incorrect" do
    it "returns 401 and error message" do
      salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret("correct_password", salt)
      DB[:users].insert(username: username, password_hash: password_hash, salt: salt)

      env = build_env({username: username, password: "wrong_password"})
      status, headers, body = LoginController.call(env)

      expect(status).to eq(401)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Invalid credentials")
    end
  end

  context "when username or password is missing" do
    it "returns 422 if username is missing" do
      env = build_env({password: "123"})
      status, headers, body = LoginController.call(env)

      expect(status).to eq(422)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Missing username or password")
    end

    it "returns 422 if password is missing" do
      env = build_env({username: "someone"})
      status, headers, body = LoginController.call(env)

      expect(status).to eq(422)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Missing username or password")
    end
  end

  context "when JSON is malformed" do
    it "returns 400 with JSON format error" do
      env = {
        "REQUEST_METHOD" => "POST",
        "rack.input" => StringIO.new("{invalid_json")
      }

      status, headers, body = LoginController.call(env)

      expect(status).to eq(400)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Invalid JSON format")
    end
  end
end
