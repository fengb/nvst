class DbBackupJob < ApplicationJob
  queue_as :default

  TMP = 'tmp/db-backup.sql'

  def perform(target = ENV['NVST_DB_BACKUP'], message = ENV['NVST_DB_BACKUP_MSG'])
    require 'git'
    require 'open3'

    db_dump!(ActiveRecord::Base.configurations[Rails.env], TMP)

    if target.present?
      FileUtils.mv TMP, target
    end

    if message.present?
      commit!(target, message)
    end
  end

  def db_dump!(config, filename)
    env = { 'PGPASSWORD' => config['password'] }
    cmd = <<-CMD.squish
      pg_dump
        --data-only
        --no-owner
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

  def commit!(filename, message)
    dirname, filename = File.split(filename)

    git = Git.open(dirname)
    git.add(filename)
    if %w[M A].include?(git.status[filename].type)
      puts git.commit(message)
    end
  end
end
