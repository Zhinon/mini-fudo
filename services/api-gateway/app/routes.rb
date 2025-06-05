require_relative './controllers/hello_controller'

module Routes
  def self.call(env)
    req = Rack::Request.new(env)

    case [req.request_method, req.path_info]
    when ['GET', '/hello']
      HelloController.hello
    else
      [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not found"}']]
    end
  end
end
