Sequel.migration do
  up do
    add_column :bins, :expire_date, DateTime
    from(:bins).where(expire_date: nil).update(expire_date: Time.now.utc + (7 * 24 * 60 * 60))
  end

  down do
    drop_column :bins, :expire_date
  end
end
