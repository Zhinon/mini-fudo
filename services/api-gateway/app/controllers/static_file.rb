require 'digest'

module StaticControllers
  class StaticFileController
    PUBLIC_DIR = File.expand_path('../../../static', __FILE__)

    FILE_CONFIG = {
      '/openapi.yaml' => {
        filename: 'openapi.yaml',
        content_type: 'application/yaml',
        cache_control: 'no-store'
      },
      '/AUTHORS' => {
        filename: 'AUTHORS',
        content_type: 'text/plain',
        cache_control: 'public, max-age=86400'  # 24 hs
      }
    }

    def self.call(env)
      req = Rack::Request.new(env)
      config = FILE_CONFIG[req.path_info]
      return not_found unless config

      full_path = File.join(PUBLIC_DIR, config[:filename])
      return not_found unless File.exist?(full_path)

      content = File.read(full_path)
      etag = %("#{Digest::SHA256.hexdigest(content)}")

      if env['HTTP_IF_NONE_MATCH'] == etag
        return [304, { 'ETag' => etag }, []]
      end

      headers = {
        'Content-Type' => config[:content_type],
        'Cache-Control' => config[:cache_control],
        'ETag' => etag
      }

      [200, headers, [content]]
    end

    def self.not_found
      [404, { 'Content-Type' => 'application/json' }, [{ error: 'File not found' }.to_json]]
    end
  end
end
