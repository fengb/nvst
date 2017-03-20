json.data do
  json.labels portfolio.dates.to_a
  json.series do
    json.array! ['portfolio'] do
      json.name 'Portfolio'
      json.data portfolio.dates.map{ |date| portfolio.value_on(date).round(2).to_f }
    end

    json.array! ['benchmark'] do
      json.name 'Benchmark'
      json.data portfolio.dates.map{ |date| portfolio.benchmark_value_on(date).round(2).to_f }
    end
  end
end
