require 'digest'

module StaticControllers
  class StaticFileController
    def self.call(env)
      req = Rack::Request.new(env)

      return not_found unless req.path_info == '/openapi.yaml'

      path = File.expand_path('../../../static/openapi.yaml', __FILE__)
      return not_found unless File.exist?(path)

      content = File.read(path)
      etag = %("#{Digest::SHA256.hexdigest(content)}")

      if req.get_header('HTTP_IF_NONE_MATCH') == etag
        return [304, { 'ETag' => etag }, []]
      end

      headers = {
        'Content-Type' => 'application/yaml',
        'Cache-Control' => 'no-store',
        'ETag' => etag
      }

      [200, headers, [content]]
    end

    def self.not_found
      [404, { 'Content-Type' => 'application/json' }, [{ error: 'File not found' }.to_json]]
    end
  end
end
