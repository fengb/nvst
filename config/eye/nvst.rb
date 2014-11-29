module Eye::Nvst
  def self.start_with(*process_names)
    root = File.expand_path('../../..', __FILE__)

    Eye.config do
      logger "#{root}/log/eye.log"
    end

    Eye.application 'nvst' do
      self.working_dir root

      process_names.each do |process_name|
        process process_name, &Eye::Nvst.processes[process_name]
      end
    end
  end

  def self.process(name, &block)
    processes[name] = block
  end

  def self.processes
    @processes ||= {}
  end
end
