require 'rufus-scheduler'
#require_relative 'environment' # preload Rails

def handle(job_name)
  pid = fork do
    require_relative 'environment'
    job_name.camelize.constantize.perform_now
  end

  Process.detach pid
end

scheduler = Rufus::Scheduler.new

scheduler.cron('0  * * * *') { handle('db_backup_job') }
scheduler.cron('0 23 * * *') { handle('populate_investments_job') }

scheduler.join
