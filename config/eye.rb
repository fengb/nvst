root = ENV['NVST_ROOT'] || File.expand_path('../..', __FILE__)

env =  ENV['NVST_ENV']  || 'development'
port = ENV['NVST_PORT'] || 8080

Eye.config do
  logger "#{root}/log/eye.log"
end

Eye.application 'nvst' do
  working_dir root

  process 'unicorn' do
    pid_file 'tmp/pids/unicorn.pid'
    start_command "bundle exec unicorn -Dc config/unicorn.rb -E #{env} -l #{port}"
    stop_command 'kill -QUIT {PID}'
    stdall "log/unicorn.log"

    # stop signals:
    # http://unicorn.bogomips.org/SIGNALS.html
    stop_signals [:TERM, 10.seconds]

    # soft restart
    restart_command 'kill -USR2 {PID}'

    check :cpu, every: 30, below: 80, times: 3
    check :memory, every: 30, below: 200.megabytes, times: [3, 5]

    start_timeout 100.seconds
    restart_grace 30.seconds

    monitor_children do
      check :cpu, every: 30, below: 80, times: 3
      check :memory, every: 30, below: 200.megabytes, times: [3, 5]
    end
  end
end
