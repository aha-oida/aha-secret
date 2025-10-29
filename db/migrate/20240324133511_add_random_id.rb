Sequel.migration do
  change do
    add_column :bins, :random_id, String
    add_index :bins, :random_id, unique: true
  end
end
