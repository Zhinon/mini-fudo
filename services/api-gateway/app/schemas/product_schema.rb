require 'dry-validation'

module Schemas
    ProductSchema = Dry::Schema.Params do
        required(:name).filled(:string)
    end
end
