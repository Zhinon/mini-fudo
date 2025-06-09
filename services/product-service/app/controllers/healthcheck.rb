class HealthcheckController
  def self.call(_env)
    [200, { 'Content-Type' => 'application/json' }, [{status:'ok'}.to_json]]
  end
end
