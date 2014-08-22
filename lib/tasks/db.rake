namespace :db do
  task :backup do
    db = Nvst::Application.config.database_configuration['default']

    sh <<-CMD.gsub(/^ */, '').gsub(/\n+/, ' ')
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
  end

  namespace :test do
    task :prepare => :environment do
      Rake::Task["db:seed"].invoke
    end
  end
end
