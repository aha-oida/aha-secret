Sequel.migration do
  change do
    # This migration is intentionally left blank.
    # The bins.id primary key (and any previous random_id handling)
    # is now fully defined in the initial create_bins migration
    # (20240322074525_create_bins), so no additional columns or
    # indexes are added here.
  end
end
