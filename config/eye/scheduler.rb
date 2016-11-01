require_relative 'nvst'

Eye::Nvst.process 'clockwork' do
  pid_file 'tmp/pids/scheduler.pid'
  stdall 'log/scheduler.log'
  start_command 'bin/nvst bundle exec ruby config/schedule.rb'
  daemonize true

  check :cpu, every: 30.seconds, below: 20, times: 3
  check :memory, every: 30.seconds, below: 200.megabytes, times: [3, 5]

  monitor_children do
    check :runtime, every: 1.minute, below: 10.minutes
  end
end
