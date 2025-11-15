Sequel.migration do
  change do
    add_column :bins, :expire_date, DateTime, default: Sequel.lit("datetime('now','+7 day','localtime')")
  end
end
