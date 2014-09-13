listen Integer(ENV['NVST_PORT'] || 8080)
worker_processes Integer(ENV['NVST_WORKERS'] || 3)

if RACKUP[:daemonize]
  pid 'tmp/pids/unicorn.pid'
  stdout_path 'log/unicorn.log'
  stderr_path 'log/unicorn.log'
end

timeout 30
preload_app true

before_fork do |server, worker|
  # Kill obsolete server (USR2 signal)
  old_pid = 'tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
