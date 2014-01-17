json.array! @growth.dates do |date|
  json.date  date
  json.value @growth.value_at(date)
end
