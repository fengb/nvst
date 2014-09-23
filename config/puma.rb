bind "tcp://127.0.0.1:#{ENV['NVST_PORT'] || 8080}"
workers Integer(ENV['NVST_WORKERS'] || 2)

if @options[:daemon]
  pidfile 'tmp/pids/puma.pid'
  stdout_redirect 'log/puma.log', 'log/puma.log', true
end

preload_app!

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
