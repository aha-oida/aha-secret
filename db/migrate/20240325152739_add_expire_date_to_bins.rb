class AddExpireDateToBins < ActiveRecord::Migration[7.1]
  def change
    add_column :bins, :expire_date, :datetime, default: Time.now + 7.days
  end
end
