require 'clockwork'
#require_relative 'environment' # preload Rails

module Clockwork
  handler do |job_name|
    pid = fork do
      require_relative 'environment'

      job_name = job_name.gsub /(_job)?$/, '_job'
      job_class = job_name.camelize.constantize
      job_class.perform
    end

    Process.detach pid
  end

  every 1.hour, 'db_backup', at: '**:00'
  every 1.day,  'populate_investments', at: '22:00', if: ->(t) { (1..5).include? t.wday }
end
