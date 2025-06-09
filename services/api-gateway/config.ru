require_relative 'config/boot'
require 'rack/deflater'
require 'app'
require 'middlewares/auth_middleware'

use Rack::Deflater
use AuthMiddleware

run App
