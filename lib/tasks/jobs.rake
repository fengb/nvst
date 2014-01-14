task :jobs => 'jobs:list'
namespace 'jobs' do
  desc 'List all fengb jobs'
  task :list do |t|
    Dir[Rails.root + 'app/jobs/*'].sort.each do |filename|
      puts "rake jobs:run[#{File.basename(filename).chomp('_job.rb')}]"
    end
  end

  desc 'Run a fengb job'
  task :run, [:name] => :environment do |t, args|
    filename = args[:name].underscore.sub(/(_job)?$/, '_job')
    fullpath = Rails.root + "app/jobs/#{filename}.rb"
    raise "Job[#{args[:name]}] not found" unless File.exists?(fullpath)
    require filename
    job = filename.camelize.constantize
    job.perform
  end
end
