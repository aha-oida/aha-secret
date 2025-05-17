Sequel.migration do
  change do
    set_column_default :bins, :expire_date, Sequel.lit("datetime('now','+7 day','localtime')")
    add_column :bins, :expire_date, DateTime, default: Sequel.lit("datetime('now','+7 day','localtime')")
  end
end
