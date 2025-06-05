class HelloController
    def self.hello
      [200, { 'Content-Type' => 'application/json' }, ['{"message":"Hello from api!!gateway!"}']]
    end
  end
