class RenameRandomIdToId < ActiveRecord::Migration[7.1]
  def change
    rename_column :bins, :random_id, :id
  end
end
