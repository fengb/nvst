task :job => 'job:list'
namespace 'job' do
  desc 'List all nvst jobs'
  task :list => :environment do |t|
    Job.all.each do |name|
      puts "rake job:run[#{name}]"
    end
  end

  desc 'Run nvst job'
  task :run, [:name] => :environment do |t, args|
    Job.run(args[:name])
  end
end
