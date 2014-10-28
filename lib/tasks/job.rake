task :job => 'job:list'
namespace 'job' do
  desc 'List all nvst jobs'
  task :list do |t|
    require 'job'
    Job.all.each do |name|
      puts "rake job:run[#{name}]"
    end
  end

  desc 'Run nvst job'
  task :run, [:name] do |t, args|
    require 'job'
    Job.run(args[:name])
  end
end
