namespace :db do
  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
    end
  end

  desc 'Backup the database (options: TARGET=file, COMMIT=msg)'
  task :backup do
    target = ENV['TARGET']
    commit = ENV['COMMIT']

    db = Nvst::Application.config.database_configuration['default']

    cmd = <<-CMD.gsub(/^ */, '').gsub(/\n+/, ' ')
      PGPASSWORD="#{db['password']}"
      pg_dump
        --data-only
        --no-owner
        --exclude-table=investment_*
        --exclude-table=schema_migrations
        --username='#{db['username']}'
        --host='#{db['host']}'
        --port='#{db['port']}'
        '#{db['database']}'
      |
      sed
        -e 's/^--.*//'
        -e '/^ *$/d'
    CMD

    verbose false do
      if target.nil?
        sh cmd
      else
        sh "#{cmd} > tmp"
        mv 'tmp', target
      end
    end

    if commit
      cd File.dirname(target) do
        sh "git commit fengb_nvst.sql --message='#{commit}'"
      end
    end
  end
end
