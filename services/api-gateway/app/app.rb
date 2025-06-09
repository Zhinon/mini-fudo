require 'routes'

class App
  def self.call(env)
    Routes.call(env)
  end
end
