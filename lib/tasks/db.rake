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
        sh "#{cmd} > tmp/db-backup.sql"
        mv 'tmp/db-backup.sql', target
      end

      if commit
        dirname, filename = File.split(target)

        git = Git.open(dirname)
        git.add(filename)
        if %w[M A].include?(git.status[filename].type)
          puts git.commit(commit)
        end
      end
    end
  end
end
