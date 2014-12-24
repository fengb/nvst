class Schwab
  DATE_FORMAT = '%m/%d/%Y'

  def self.parse(string)
    [].tap do |array|
      CSV.parse(string) do |row|
        next if row[0] !~ /^[0-9]/

        array << hash = {
          date:        parse_string(row[0]),
          action:      parse_string(row[1]),
          symbol:      parse_string(row[2]),
          description: parse_string(row[3]),
          quantity:    parse_number(row[4]),
          price:       parse_number(row[5]),
          fees:        parse_number(row[6]),
          amount:      parse_number(row[7])
        }

        if hash[:date] =~ /as of/
          date, as_of = hash[:date].split('as of')
          hash[:date] = Date.strptime(date.strip, DATE_FORMAT)
          hash[:as_of] = Date.strptime(as_of.strip, DATE_FORMAT)
        else
          hash[:date] = Date.strptime(hash[:date], DATE_FORMAT)
        end
      end
    end
  end

  def self.parse_string(snippet)
    snippet = snippet.strip
    snippet.empty? ? nil : snippet
  end

  def self.parse_number(snippet)
    snippet = parse_string(snippet)
    snippet && BigDecimal(snippet.sub('$', ''))
  end
end
