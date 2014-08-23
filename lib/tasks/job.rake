task :job => 'job:list'
namespace 'job' do
  desc 'List all nvst jobs'
  task :list do |t|
    Dir[Rails.root + 'app/jobs/*'].sort.each do |filename|
      puts "rake job:run[#{File.basename(filename).chomp('_job.rb')}]"
    end
  end

  desc 'Run nvst job'
  task :run, [:name] => :environment do |t, args|
    if args[:name].nil?
      Rake::Task['job:list'].invoke
      next
    end

    filename = args[:name].underscore.sub(/(_job)?$/, '_job')
    fullpath = Rails.root + "app/jobs/#{filename}.rb"
    raise "Job[#{args[:name]}] not found" unless File.exists?(fullpath)
    require filename
    job = filename.camelize.constantize
    job.perform
  end
end
