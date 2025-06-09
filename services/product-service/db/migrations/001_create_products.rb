Sequel.migration do
    change do
        create_table(:products) do
            primary_key :id
            String :name, null: false
            Integer :user_id, null: false
            index :user_id
            unique [:user_id, :name]
        end
    end
end
