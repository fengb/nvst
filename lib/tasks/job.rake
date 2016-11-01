desc 'Run ActiveJob'
task :job, [:name?] => :environment do |t, args|
  if args[:name?]
    args[:name?].camelize.constantize.perform_now
  else
    RailsUtil.all(:jobs).each do |name|
      puts "rake job[#{name}]"
    end
  end
end
