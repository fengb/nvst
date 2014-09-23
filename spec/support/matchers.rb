require 'rspec/expectations'

RSpec::Matchers.define :have_valid do |field|
  match do |record|
    record.valid? || !record.errors.include?(field)
  end
end
