describe ProductsController do
  def build_env(params = {})
    {
      "REQUEST_METHOD" => "GET",
      "QUERY_STRING" => URI.encode_www_form(params)
    }
  end

  let(:json_header) { {"Content-Type" => "application/json"} }

  context "when user_id is valid and products exist" do
    it "returns 200 and serialized products" do
      DB[:products].insert(id: 1, name: "Mate", user_id: 123)
      DB[:products].insert(id: 2, name: "Café", user_id: 123)

      env = build_env({"user_id" => "123"})
      status, headers, body = ProductsController.call(env)

      expect(status).to eq(200)
      expect(headers).to eq(json_header)

      json = JSON.parse(body.first)
      expect(json).to eq([
        {"id" => 1, "name" => "Mate"},
        {"id" => 2, "name" => "Café"}
      ])
    end
  end

  context "when user_id is valid but has no products" do
    it "returns 200 with empty array" do
      env = build_env({"user_id" => "999"})
      status, headers, body = ProductsController.call(env)

      expect(status).to eq(200)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)).to eq([])
    end
  end

  context "when user_id is missing" do
    it "returns 400 and error message" do
      env = build_env
      status, headers, body = ProductsController.call(env)

      expect(status).to eq(400)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Missing or invalid user_id")
    end
  end

  context "when user_id is invalid (non-numeric or <= 0)" do
    it "returns 400 when user_id is 0" do
      env = build_env({"user_id" => "0"})
      status, headers, body = ProductsController.call(env)

      expect(status).to eq(400)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Missing or invalid user_id")
    end

    it "returns 400 when user_id is negative" do
      env = build_env({"user_id" => "-5"})
      status, headers, body = ProductsController.call(env)

      expect(status).to eq(400)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Missing or invalid user_id")
    end

    it "returns 400 when user_id is non-numeric" do
      env = build_env({"user_id" => "abc"})
      status, headers, body = ProductsController.call(env)

      expect(status).to eq(400)
      expect(headers).to eq(json_header)
      expect(JSON.parse(body.first)["error"]).to eq("Missing or invalid user_id")
    end
  end
end
