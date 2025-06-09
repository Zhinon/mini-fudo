require_relative 'config/boot'
require 'db'
require 'routes'

class App
  def self.call(env)
    Routes.call(env)
  end
end
