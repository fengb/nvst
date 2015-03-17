require 'git'
require 'open3'

module Job
  class DbBackup
    TMP = 'tmp/db-backup.sql'
    TARGET = ENV['NVST_DB_BACKUP']
    MESSAGE = ENV['NVST_DB_BACKUP_MSG']

    def self.perform
      db_dump!(Nvst::Application.config.database_configuration['default'], TMP)

      if target.present?
        FileUtils.mv TMP, TARGET
      end

      if message.present?
        commit!(TARGET, MESSAGE)
      end
    end

    def self.db_dump!(config, filename)
      env = { 'PGPASSWORD' => config['password'] }
      opts = {}
      cmd = <<-CMD.squish
        pg_dump
          --data-only
          --no-owner
          --exclude-table=investment_*
          --exclude-table=schema_migrations
          --username='#{config['username']}'
          --host='#{config['host']}'
          --port='#{config['port']}'
          '#{config['database']}'
      CMD

      out, err, status = Open3.capture3(env, cmd)
      raise err unless status.success?
      IO.write(filename, out.gsub(/^--.*/, '').squeeze("\n"))
    end

    def self.commit!(filename, message)
      dirname, filename = File.split(filename)

      git = Git.open(dirname)
      git.add(filename)
      if %w[M A].include?(git.status[filename].type)
        puts git.commit(message)
      end
    end
  end
end
