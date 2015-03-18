require 'simplecov'
SimpleCov.start

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.order = "random"
end
