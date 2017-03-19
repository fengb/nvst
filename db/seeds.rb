path = File.dirname(__FILE__)
seedfile = if File.exists?(path + '/seeds_local.sql')
             path + '/seeds_local.sql'
           else
             path + '/seeds.sql'
           end

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
