json.cache! portfolio do
  json.array! portfolio.dates do |date|
    json.name :portfolio
    json.date date
    json.value portfolio.value_at(date).round(2)
  end

  json.array! portfolio.dates do |date|
    json.name :benchmark
    json.date date
    json.value portfolio.benchmark_value_at(date).round(2)
  end
end
