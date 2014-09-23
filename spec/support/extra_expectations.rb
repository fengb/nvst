require 'rspec/expectations'

RSpec::Matchers.define :have_valid do |field|
  match do |record|
    record.valid? || !record.errors.include?(field)
  end
end

module ExtraExpectations
  def expect_data(obj, *datas)
    match = {}
    datas.each do |data|
      match.merge!(data)
    end

    match.each do |method, value|
      expect(obj.send method).to eq(value)
    end
  end
end
