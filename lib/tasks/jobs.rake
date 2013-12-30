task :jobs => 'jobs:list'
namespace 'jobs' do
  desc 'List all fengb jobs'
  task :list do |t|
    Dir[Rails.root + 'app/jobs/*'].each do |filename|
      puts "rake jobs:run[#{File.basename(filename, '.*')}]"
    end
  end

  desc 'Run a fengb job'
  task :run, [:name] => :environment do |t, args|
    filename = args[:name].underscore
    fullpath = Rails.root + "app/jobs/#{filename}.rb"
    raise "Job[#{filename.camelize}] not found" unless File.exists?(fullpath)
    require filename
    job = args[:name].camelize.constantize
    job.perform
  end
end
