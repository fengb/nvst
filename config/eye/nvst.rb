module Eye::Nvst
  def self.start_with(web)
    root = File.expand_path('../../..', __FILE__)

    Eye.config do
      logger "#{root}/log/eye.log"
    end

    Eye.application 'nvst' do
      working_dir root

      process web, &Eye::Nvst.webs[web]

      Eye::Nvst.processes.each do |name, block|
        process name, &block
      end
    end
  end

  def self.process(name, &block)
    processes[name] = block
  end

  def self.web(name, &block)
    webs[name] = block
  end

  def self.processes
    @processes ||= {}
  end

  def self.webs
    @webs ||= {}
  end
end
