describe RegisterController do
  def build_env(body)
    {
      "REQUEST_METHOD" => "POST",
      "rack.input" => StringIO.new(body.to_json)
    }
  end

  let(:json_header) { {"Content-Type" => "application/json"} }

  context "when registration is valid" do
    it "returns 201 and success message" do
      env = build_env({username: "newuser", password: "strongpass"})

      status, headers, body = RegisterController.call(env)

      expect(status).to eq(201)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["status"]).to eq("User created")
    end
  end

  context "when username already exists" do
    it "returns 409 and error message" do
      # Insert a user first
      DB[:users].insert(
        username: "existing",
        password_hash: "irrelevant",
        salt: "irrelevant"
      )

      env = build_env({username: "existing", password: "whatever"})

      status, headers, body = RegisterController.call(env)

      expect(status).to eq(409)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Username already exists")
    end
  end

  context "when fields are missing" do
    it "returns 422 when username is missing" do
      env = build_env({password: "pass"})

      status, headers, body = RegisterController.call(env)

      expect(status).to eq(422)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Missing username or password")
    end

    it "returns 422 when password is missing" do
      env = build_env({username: "user"})

      status, headers, body = RegisterController.call(env)

      expect(status).to eq(422)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Missing username or password")
    end
  end

  context "when JSON is malformed" do
    it "returns 400 with error message" do
      env = {
        "REQUEST_METHOD" => "POST",
        "rack.input" => StringIO.new("{bad_json")
      }

      status, headers, body = RegisterController.call(env)

      expect(status).to eq(400)
      expect(headers).to eq(json_header)
      json = JSON.parse(body.first)
      expect(json["error"]).to eq("Invalid JSON format")
    end
  end
end
