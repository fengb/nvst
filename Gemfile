source 'https://rubygems.org'

gem 'rails'
gem 'git', require: false

# Server
gem 'unicorn', require: false
gem 'puma', require: false
gem 'clockwork', require: false

# Third Party
gem 'yahoo-finance', git: 'https://github.com/fengb/yahoo-finance.git', branch: 'master'

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
  gem 'big_decimal_helper'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ffaker'
  gem 'pry'
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
