require 'dry-validation'

module Schemas
    LoginSchema = Dry::Schema.Params do
        required(:username).filled(:string)
        required(:password).filled(:string)
    end

    RegisterSchema = Dry::Schema.Params do
        required(:username).filled(:string, min_size?: 3)
        required(:password).filled(:string, min_size?: 6)
    end
end
