# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:bins) do
      String :id, primary_key: true, null: false
      Text :payload
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
