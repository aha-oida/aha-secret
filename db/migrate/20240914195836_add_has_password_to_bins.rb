class AddHasPasswordToBins < ActiveRecord::Migration[7.2]
  def change
    add_column :bins, :has_password, :boolean, default: false
  end
end
