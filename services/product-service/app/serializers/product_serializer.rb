module ProductSerializer
  def self.call(product)
    {
      id: product[:id],
      name: product[:name]
    }
  end
end
