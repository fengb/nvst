desc 'Run ActiveJob'
task :job, [:name?] => :environment do |t, args|
  if args[:name?]
    args[:name?].camelize.sub(/(Job)?$/, 'Job').constantize.perform_now
  else
    RailsUtil.all(:jobs).each do |klass|
      puts "rake job[#{klass.name.underscore.sub('_job', '')}]"
    end
  end
end
