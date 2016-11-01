require 'rufus-scheduler'
#require_relative 'environment' # preload Rails

def handle(job_name)
  pid = fork do
    require_relative '../lib/job'
    Job.run(job_name)
  end

  Process.detach pid
end

scheduler = Rufus::Scheduler.new

scheduler.cron('0  * * * *') { handle('db_backup') }
scheduler.cron('0 23 * * *') { handle('populate_investments') }

scheduler.join
