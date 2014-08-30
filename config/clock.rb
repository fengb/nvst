require_relative 'environment' # boot up Rails
require 'clockwork'

module Clockwork
  handler do |job_name|
    job_name = job_name.gsub /(_job)?$/, '_job'
    job_class = job_name.camelize.constantize
    job_class.perform
  end

  every 1.hour, 'db_backup', at: '**:00'
  every 1.day,  'populate_investments', at: '22:00', if: ->(t) { (1..5).include? t.wday }
end
