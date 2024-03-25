class AddExpireDateToBins < ActiveRecord::Migration[7.1]
  def change
    add_column :bins, :expire_date, :datetime, default: -> { "datetime('now','+7 day','localtime')" }
  end
end
