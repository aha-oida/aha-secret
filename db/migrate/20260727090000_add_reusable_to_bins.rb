# frozen_string_literal: true

Sequel.migration do
  up do
    add_column :bins, :reusable, TrueClass, default: false, null: false
  end

  down do
    drop_column :bins, :reusable
  end
end
