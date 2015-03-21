module TestServer
  class << self
    DEFAULT_PORT = 43198

    def url(port: DEFAULT_PORT)
      "http://localhost:#{port}"
    end

    def start(port: DEFAULT_PORT, app: Rails.application)
      if servers[port]
        $stderr.puts "Already started server on #{port}"
        return
      end

      mutex = Mutex.new
      server_ready = ConditionVariable.new
      thread = Thread.new do
        Rack::Handler::WEBrick.run(app, Port: port, Logger: logger, AccessLog: []) do |s|
          mutex.synchronize { server_ready.signal }
        end
      end
      mutex.synchronize { server_ready.wait(mutex) }

      servers[port] = thread

      url(port: port)
    end

    def stop(port: DEFAULT_PORT, wait: true)
      thread = servers.delete(port)
      if thread.nil?
        $stderr.puts "No server on #{port}"
        return
      end

      thread.kill
      thread.join if wait
    end

    def stop_all
      servers.each do |port, thread|
        stop(port: port, wait: false)
      end
    end

    def servers
      @servers ||= {}
    end

    def logger
      @logger = WEBrick::Log.new(File::NULL)
    end
  end
end
