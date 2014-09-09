root = ENV['NVST_ROOT'] || File.expand_path('../..', __FILE__)

require 'dotenv'
Dotenv.overload "#{root}/.env"

env = ENV['NVST_ENV']  || 'development'
port = ENV['NVST_PORT'] || 8080

Eye.config do
  logger "#{root}/log/eye.log"
end

Eye.application 'nvst' do
  working_dir root

  process 'clockwork' do
    pid_file 'tmp/pids/clockwork.pid'
    stdall 'log/clockwork.log'
    start_command 'bundle exec clockwork config/clockwork.rb'
    daemonize true

    check :cpu, every: 30.seconds, below: 20, times: 3
    check :memory, every: 30.seconds, below: 200.megabytes, times: [3, 5]

    monitor_children do
      check :runtime, every: 1.minute, below: 10.minutes
    end
  end

  def process_server(name=nil, &block)
    if name == ENV['NVST_SERVER'] && !name.nil?
      @process_server = name
      process(name, &block)
    end

    @process_server
  end

  process_server 'unicorn' do
    pid_file 'tmp/pids/unicorn.pid'
    start_command "bundle exec unicorn -Dc config/unicorn.rb -E #{env} -l #{port}"
    stop_command 'kill -QUIT {PID}'

    # stop signals:
    # http://unicorn.bogomips.org/SIGNALS.html
    stop_signals [:TERM, 10.seconds]

    # soft restart
    restart_command 'kill -USR2 {PID}'

    check :cpu, every: 30.seconds, below: 20, times: 3
    check :memory, every: 30.seconds, below: 200.megabytes, times: [3, 5]

    start_timeout 100.seconds
    restart_grace 30.seconds

    monitor_children do
      stop_command 'kill -QUIT {PID}'
      check :cpu, every: 30.seconds, below: 80, times: 3
      check :memory, every: 30.seconds, below: 200.megabytes, times: [3, 5]
    end
  end

  process_server 'puma' do
    pid_file 'tmp/pids/puma.pid'
    start_command "bundle exec puma -d -C config/puma.rb -e #{env} -p #{port}"
    stop_command 'kill -QUIT {PID}'
    restart_command 'kill -USR2 {PID}'

    check :cpu, every: 30.seconds, below: 20, times: 3
    check :memory, every: 30.seconds, below: 200.megabytes, times: [3, 5]

    start_timeout 100.seconds
    restart_grace 30.seconds

    monitor_children do
      stop_command 'kill -QUIT {PID}'
      check :cpu, every: 30.seconds, below: 80, times: 3
      check :memory, every: 30.seconds, below: 200.megabytes, times: [3, 5]
    end
  end

  if process_server.nil?
    raise "Cannot find NVST_SERVER='#{ENV['NVST_SERVER']}'"
  end
end
