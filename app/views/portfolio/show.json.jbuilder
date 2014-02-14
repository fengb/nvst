json.portfolio @portfolio.dates do |date|
  json.date  date
  json.value @portfolio.value_at(date).round(2)
end

json.benchmark @portfolio.dates do |date|
  json.date  date
  json.value @portfolio.benchmark_value_at(date).round(2)
end
