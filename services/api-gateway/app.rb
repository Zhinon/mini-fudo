require_relative './app/routes'

class App
  def self.call(env)
    Routes.call(env)
  end
end
