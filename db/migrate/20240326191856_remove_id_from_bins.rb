class RemoveIdFromBins < ActiveRecord::Migration[7.1]
  def change
    remove_column :bins, :id
  end
end
