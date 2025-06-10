require "rack"
require "json"
require "rspec"
require "stringio"
require "digest"
require "webmock/rspec"

require "controllers/static_file"

describe StaticControllers::StaticFileController do
  let(:headers) do
    {}
  end

  def build_env(path, custom_headers = {})
    {
      "REQUEST_METHOD" => "GET",
      "PATH_INFO" => path,
      "rack.input" => StringIO.new("")
    }.merge(custom_headers)
  end

  after(:each) do
    WebMock.reset!
  end

  let(:openapi_path_info) { "/openapi.yaml" }
  let(:authors_path_info) { "/AUTHORS" }

  let(:openapi_full_path) { File.expand_path("../../../static/openapi.yaml", __FILE__) }
  let(:authors_full_path) { File.expand_path("../../../static/AUTHORS", __FILE__) }

  let(:openapi_content) { "swagger: '2.0'\ninfo:\n  title: API Gateway\n" }
  let(:authors_content) { "Author One\nAuthor Two\n" }

  let(:openapi_etag) { %("#{Digest::SHA256.hexdigest(openapi_content)}") }
  let(:authors_etag) { %("#{Digest::SHA256.hexdigest(authors_content)}") }

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(openapi_full_path).and_return(true)
    allow(File).to receive(:exist?).with(authors_full_path).and_return(true)

    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(openapi_full_path).and_return(openapi_content)
    allow(File).to receive(:read).with(authors_full_path).and_return(authors_content)
  end

  context "when requesting /openapi.yaml" do
    let(:env) { build_env(openapi_path_info) }

    it "returns a 200 OK status with correct content type and cache headers" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("application/yaml")
      expect(headers["Cache-Control"]).to eq("no-store")
      expect(headers["ETag"]).to eq(openapi_etag)
      expect(body.first).to eq(openapi_content)
    end

    it "returns a 304 Not Modified status if If-None-Match header matches ETag" do
      env_with_etag = build_env(openapi_path_info, {"HTTP_IF_NONE_MATCH" => openapi_etag})
      status, headers, body = described_class.call(env_with_etag)
      expect(status).to eq(304)
      expect(headers["ETag"]).to eq(openapi_etag)
      expect(body).to be_empty
    end
  end

  context "when requesting /AUTHORS" do
    let(:env) { build_env(authors_path_info) }

    it "returns a 200 OK status with correct content type and cache headers" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("text/plain")
      expect(headers["Cache-Control"]).to eq("public, max-age=86400")
      expect(headers["ETag"]).to eq(authors_etag)
      expect(body.first).to eq(authors_content)
    end

    it "returns a 304 Not Modified status if If-None-Match header matches ETag" do
      env_with_etag = build_env(authors_path_info, {"HTTP_IF_NONE_MATCH" => authors_etag})
      status, headers, body = described_class.call(env_with_etag)
      expect(status).to eq(304)
      expect(headers["ETag"]).to eq(authors_etag)
      expect(body).to be_empty
    end
  end

  context "when requesting an unconfigured file path" do
    let(:env) { build_env("/unconfigured_file.txt") }

    it "returns a 404 Not Found status" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(404)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq({"error" => "File not found"})
    end
  end

  context "when requesting a configured file that does not exist on disk" do
    let(:env) { build_env("/openapi.yaml") }

    before do
      allow(File).to receive(:exist?).with(openapi_full_path).and_return(false)
    end

    it "returns a 404 Not Found status" do
      status, headers, body = described_class.call(env)
      expect(status).to eq(404)
      expect(headers["Content-Type"]).to eq("application/json")
      expect(JSON.parse(body.first)).to eq({"error" => "File not found"})
    end
  end
end
