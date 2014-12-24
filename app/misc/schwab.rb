class Schwab
  DATE_FORMAT = '%m/%d/%Y'

  EVENTS = {
    'Qualified Dividend' => 'dividend - qualified',
    'Cash Dividend'      => 'dividend - tax-exempt',
    'Bank Interest'      => 'interest',
    'Margin Interest'    => 'interest - margin',
  }

  def self.process!(string)
    directives = parse(string)
    investments_lookup = Investment.lookup_by_symbol
    process_trades!(directives, investments_lookup)
    process_events!(directives, investments_lookup)
  end

  def self.process_trades!(directives, investments_lookup)
    trade_directives = directives.select { |d| d[:action] == 'Buy' || d[:action] == 'Sell' }

    start_date = trade_directives.last[:date]
    trades = Trade.where('date >= ?', start_date).includes(:investment)

    trade_data = trade_directives.map do |directive|
      direction = directive[:action] == 'Buy' ? 1 : -1
      data = {
        date:       directive[:date],
        investment: investments_lookup[directive[:symbol]],
        shares:     direction * directive[:quantity],
        price:      directive[:price],
        net_amount: directive[:amount],
      }
    end

    missing(trades, trade_data)
  end

  def self.process_events!(directives, investments_lookup)
    event_directives = directives.select { |d| EVENTS.has_key?(d[:action]) }

    start_date = event_directives.last[:date]
    events = Event.where('date >= ?', start_date).includes(:src_investment)

    event_data = event_directives.map do |directive|
      data = {
        date:           directive[:date],
        src_investment: directive[:symbol] ? investments_lookup[directive[:symbol]] : Investment::Cash.default,
        amount:         directive[:amount],
        category:       EVENTS[directive[:action]],
      }
    end

    missing(events, event_data)
  end

  def self.missing(elements, searches)
    searches.select do |search|
      keys = search.keys
      match = elements.find do |element|
        search.values_at(*keys) == keys.map{|k| element.send(k)}
      end
      match.nil?
    end
  end

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
