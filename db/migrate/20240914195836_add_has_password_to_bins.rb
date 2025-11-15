Sequel.migration do
  change do
    add_column :bins, :has_password, TrueClass, default: false
  end
end
