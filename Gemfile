source 'https://rubygems.org'

gem 'rails'

# Server
gem 'unicorn', require: false
gem 'puma', require: false
gem 'clockwork', require: false

# Jobs
gem 'yahoo-finance', require: false, git: 'https://github.com/fengb/yahoo-finance.git', branch: 'master'
gem 'git', require: false

# Model
gem 'pg'
gem 'schema_plus'
gem 'devise'
gem 'rails_admin'
gem 'enumerize'

# View
gem 'haml-rails'
gem 'jbuilder'

# Assets
gem 'sass-rails'
gem 'uglifier'
gem 'jquery-rails'
#Server can has node
# gem 'therubyracer', platforms: :ruby
# gem 'therubyrhino', platforms: :jruby

group :development, :test do
  gem 'dotenv-deployment'
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'pry'
  gem 'big_decimal_helper'
  gem 'did_you_mean'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'timecop'
  gem 'simplecov'
end
