module Job
  def self.run(name)
    initialize_app!

    ruby_name = "job/#{name}"
    unless File.exist?("#{Rails.root}/lib/#{ruby_name}.rb")
      raise "Job '#{name}' not found"
    end
    require ruby_name
    ruby_name.camelize.constantize.perform
  end

  def self.all
    Dir[Rails.root + 'lib/job/*.rb'].sort.map do |filename|
      File.basename(filename, '.rb')
    end
  end

  def self.initialize_app!
    unless defined?(Nvst::Application) && Nvst::Application.initialized?
      require 'config/application'
      Nvst::Application.configure do
        config.eager_load = false
        initialize!
      end
    end
  end
end
