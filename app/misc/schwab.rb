class Schwab
  EVENTS = {
    'Qualified Dividend' => 'dividend - qualified',
    'Cash Dividend'      => 'dividend - tax-exempt',
    'Bank Interest'      => 'interest',
    'Margin Interest'    => 'interest - margin',
    'Special Qual Div'   => 'dividend - qualified',
  }

  EXPIRE = ['Expired', 'Bankruptcy']
  IGNORE = ['Spin-off', 'Name Change', 'Funds Paid']

  def self.process!(csv)
    new(csv).process!
  end

  def initialize(csv)
    @csv = csv
  end

  def process!
    transformed =
      transactions.map do |t|
        case t.action
        when /^(Buy|Sell)/ then transform_trade(t)
        when *EVENTS.keys  then transform_event(t)
        when *EXPIRE       then transform_expiration(t)
        when *IGNORE       then Rails.logger.warn("Schwab - ignoring #{t.action}") && nil
        else raise TypeError.new("Unknown action #{t.action}")
        end
      end.compact

    ActiveRecord::Base.transaction do
      classes = transformed.map(&:class).uniq
      classes.each do |klass|
        existing = klass.where('date >= ?', start_date)
        records = transformed.select { |record| record.class == klass }
        missing(existing, records).each(&:save!)
      end
    end
  end

  def transform_trade(transaction)
    direction = transaction.action.start_with?('Buy') ? 1 : -1
    Trade.new(
      date:       transaction.date,
      investment: investments_lookup[transaction.standard_symbol],
      shares:     direction * transaction.quantity,
      price:      transaction.price,
      net_amount: transaction.amount,
    )
  end

  def transform_event(transaction)
    Event.new(
      date:           transaction.date,
      src_investment: transaction.standard_symbol ? investments_lookup[transaction.standard_symbol] : Investment::Cash.default,
      amount:         transaction.amount,
      category:       EVENTS[transaction.action],
    )
  end

  def transform_expiration(transaction)
    Expiration.new(
      investment: investments_lookup[transaction.standard_symbol],
      date:       transaction.date,
      shares:     transaction.quantity,
    )
  end

  def missing(existing, additionals)
    additionals.reject do |additional|
      contains_similar?(existing, additional)
    end
  end

  def contains_similar?(haystack, needle)
    attrs = needle.attributes.compact.to_set
    haystack.any? { |item| item.attributes.compact.to_set.superset?(attrs) }
  end

  private
  def transactions
    @transactions ||= Transaction.parse(@csv).sort_by(&:date)
  end

  def investments_lookup
    @investments_lookup ||= Investment.lookup_by_symbol { |sym| Investment::Stock.create!(symbol: sym, name: sym) }
  end

  def start_date
    transactions.first&.date
  end

  class Transaction
    attr_reader :raw

    OPTIONS_SYMBOL = /(?<root>[A-Z]{1,5}) (?<month>[0-9]{2})\/(?<day>[0-9]{2})\/(?<year>[0-9]{4}) (?<strike>[.0-9]+) (?<type>[CP])/
    def self.to_occ_symbol(schwab_symbol)
      match = OPTIONS_SYMBOL.match(schwab_symbol)

      [ match[:root],
        match[:year][-2..-1],
        match[:month],
        match[:day],
        match[:type],
        '%08d' % (match[:strike].to_f * 1000).round
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
