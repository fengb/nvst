class Schwab
  EVENTS = {
    'Qualified Dividend' => 'dividend - qualified',
    'Cash Dividend'      => 'dividend - tax-exempt',
    'Bank Interest'      => 'interest',
    'Margin Interest'    => 'interest - margin',
  }

  def self.process!(csv)
    transactions = Transaction.parse(csv)
    investments_lookup = Investment.lookup_by_symbol
    ActiveRecord::Base.transaction do
      process_trades!(transactions, investments_lookup)
      process_events!(transactions, investments_lookup)
    end
  end

  def self.process_trades!(transactions, investments_lookup)
    trade_transactions = transactions.select { |t| t.action =~ /^(Buy|Sell)/ }

    start_date = trade_transactions.last.date
    trades = Trade.where('date >= ?', start_date).includes(:investment)

    trade_data = trade_transactions.map do |transaction|
      direction = transaction.action == 'Buy' ? 1 : -1
      data = {
        date:       transaction.date,
        investment: investments_lookup[transaction.standard_symbol],
        shares:     direction * transaction.quantity,
        price:      transaction.price,
        net_amount: transaction.amount,
      }
    end

    Trade.create! missing(trades, trade_data)
  end

  def self.process_events!(transactions, investments_lookup)
    event_transactions = transactions.select { |t| EVENTS.has_key?(t.action) }

    start_date = event_transactions.last.date
    events = Event.where('date >= ?', start_date).includes(:src_investment)

    event_data = event_transactions.map do |transaction|
      data = {
        date:           transaction.date,
        src_investment: transaction.standard_symbol ? investments_lookup[transaction.standard_symbol] : Investment::Cash.default,
        amount:         transaction.amount,
        category:       EVENTS[transaction.action],
      }
    end

    Event.create! missing(events, event_data)
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

  class Transaction
    attr_reader :raw

    OPTIONS_SYMBOL = /([A-Z]{1,5}) ([0-9]{2})\/([0-9]{2})\/([0-9]{4}) ([.0-9]*) ([CP])/
    def self.to_occ_symbol(schwab_symbol)
      match = OPTIONS_SYMBOL.match(schwab_symbol)
      underlying_symbol = match[1]
      month = match[2]
      day = match[3]
      year = match[4]
      price = match[5]
      type = match[6]

      [ underlying_symbol,
        year[-2..-1],
        month,
        day,
        type,
        '%08d' % (price.to_f * 1000).round
      ].join
    end

    def self.parse(csv)
      [].tap do |array|
        CSV.parse(csv) do |row|
          next if row[0] !~ /^[0-9]/

          array << Transaction.new(row)
        end
      end
    end

    def initialize(row)
      @raw = {
        date:        row[0],
        action:      row[1],
        symbol:      row[2],
        description: row[3],
        quantity:    row[4],
        price:       row[5],
        fees:        row[6],
        amount:      row[7],
      }
    end

    def date
      @date ||= as_date(raw[:date])
    end

    def as_of
      @as_of ||= as_date(raw[:date].split('as of')[1])
    end

    def action
      @action ||= as_string(raw[:action])
    end

    def symbol
      @symbol ||= as_string(raw[:symbol])
    end

    def standard_symbol
      @standard_symbol ||= begin
        if symbol.nil?
          nil
        elsif OPTIONS_SYMBOL.match(symbol)
          self.class.to_occ_symbol(symbol)
        else
          symbol
        end
      end
    end

    def description
      @description ||= as_string(raw[:description])
    end

    def quantity
      @quantity ||= as_number(raw[:quantity])
    end

    def price
      @price ||= as_number(raw[:price])
    end

    def fees
      @fees ||= as_number(raw[:fees])
    end

    def amount
      @amount ||= as_number(raw[:amount])
    end

    private

    def as_date(snippet)
      return if snippet.nil?
      snippet = as_string(snippet)
      Date.strptime(snippet, '%m/%d/%Y')
    end

    def as_string(snippet)
      snippet = snippet.strip
      snippet.empty? ? nil : snippet
    end

    def as_number(snippet)
      snippet = as_string(snippet)
      snippet && BigDecimal(snippet.sub('$', ''))
    end
  end
end
