json.array! @benchmark.dates do |date|
  json.date  date
  json.value @benchmark.value_at(date)
end
