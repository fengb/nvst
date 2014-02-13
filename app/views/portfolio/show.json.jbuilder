json.portfolio @growth.dates do |date|
  json.date  date
  json.value @growth.value_at(date).round(2)
end

json.benchmark @growth.dates do |date|
  json.date  date
  json.value @growth.benchmark_value_at(date).round(2)
end
