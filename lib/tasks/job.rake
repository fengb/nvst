desc 'Run nvst job'
task :job, [:name?] do |t, args|
  require 'job'
  if args[:name?]
    Job.run(args[:name?])
  else
    Job.all.each do |name|
      puts "rake job[#{name}]"
    end
  end
end
