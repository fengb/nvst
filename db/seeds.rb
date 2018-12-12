seedfile = ENV['SEEDFILE'] || "#{__dir__}/seeds.sql"

config = ActiveRecord::Base.configurations[Rails.env]
env = { 'PGPASSWORD' => config['password'] }
cmd = <<-CMD.squish
  psql
    --file='#{seedfile}'
    --username='#{config['username']}'
    --host='#{config['host']}'
    --port='#{config['port']}'
    '#{config['database']}'
CMD
system(env, cmd)
