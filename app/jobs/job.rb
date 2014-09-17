class Job
  attr_accessor :name

  def initialize(name)
    @name = name.underscore.sub /(_job)?$/, '_job'
    begin
      underlying_class
    rescue NameError
      raise "Job '#{name}' not found"
    end
  end

  def self.run(name)
    new(name).perform
  end

  def self.all
    Dir[Rails.root + 'app/jobs/*_job.rb'].sort.map do |filename|
      File.basename(filename).chomp('_job.rb')
    end
  end

  def underlying_class
    name.camelize.constantize
  end

  def perform
    underlying_class.perform
  end
end
