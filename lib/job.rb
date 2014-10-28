module Job
  def self.run(name)
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
end
