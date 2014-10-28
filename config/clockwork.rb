require 'clockwork'
#require_relative 'environment' # preload Rails

module Clockwork
  configure do |config|
    config[:sleep_timeout] = 30
  end

  handler do |job_name|
    pid = fork do
      require 'job'
      Job.run(job_name)
    end

    Process.detach pid
  end

  every 1.hour, 'db_backup', at: '**:00'
  every 1.day,  'populate_investments', at: '23:00', if: ->(t) { (1..5).include? t.wday }
end
