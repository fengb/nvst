require 'git'


module Job
  class DbBackup
    TMP = 'tmp/db-backup.sql'
    TARGET = ENV['NVST_DB_BACKUP']
    MESSAGE = ENV['NVST_DB_BACKUP_MSG']

    def self.perform
      db = Nvst::Application.config.database_configuration['default']

      system <<-CMD.gsub(/\s+/, ' ')
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
        > "#{TMP}"
      CMD

      if TARGET.present?
        FileUtils.mv 'tmp/db-backup.sql', TARGET
      end

      if MESSAGE
        dirname, filename = File.split(TARGET)

        git = Git.open(dirname)
        git.add(filename)
        if %w[M A].include?(git.status[filename].type)
          puts git.commit(MESSAGE)
        end
      end
    end
  end
end
