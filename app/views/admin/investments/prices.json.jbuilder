json.array! @prices do |price|
  json.extract! price, :date, :high, :low, :close
  json.adjusted_close price.adjusted(:close)
end
