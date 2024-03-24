class AddRandomId < ActiveRecord::Migration[7.1]
  def change
    add_column :bins, :random_id, :string
    add_index :bins, :random_id, unique: true
  end
end
