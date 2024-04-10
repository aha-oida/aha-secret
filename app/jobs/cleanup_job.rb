class CleanupJob
  include SuckerPunch::Job
  workers 1

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Bin.cleanup
    end
  end
end
