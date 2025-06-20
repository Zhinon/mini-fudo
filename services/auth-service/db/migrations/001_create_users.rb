Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, null: false, unique: true
      String :password_hash, null: false
      String :salt, null: false
    end
  end
end
