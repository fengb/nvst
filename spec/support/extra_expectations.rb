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
