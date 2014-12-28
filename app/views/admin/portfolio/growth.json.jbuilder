json.cache! @portfolio do
  json.array! @portfolio.dates do |date|
    json.name :portfolio
    json.date date
    json.value @portfolio.value_at(date).round(2)
  end

  json.array! @portfolio.dates do |date|
    json.name :principal
    json.date date
    json.value @portfolio.principal_at(date)
  end
end
