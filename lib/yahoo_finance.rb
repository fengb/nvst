require 'csv'


module YahooFinance
  class << self
    HistoricalPrice = Struct.new('HistoricalPrice', *%w[date open high low close volumn adj_close])
    Dividend        = Struct.new('Dividend',        *%w[date amount])
    Split           = Struct.new('Split',           *%w[date before after])

    def historical_prices(symbol, options={})
      start_date = options[:start_date]
      end_date = options[:end_date]
      response = raw_ichart_request(symbol, resource: 'table.csv', start_date: start_date, end_date: end_date)

      rows = CSV.parse(response)
      # rows[0] is column names, which we have defined on line 6 already.
      rows[1..-1].map do |row|
        row_with_types = row.map do |col|
          if col =~ /-/
            Date.new(*col.split('-').map(&:to_i))
          else
            BigDecimal.new(col)
          end
        end
        HistoricalPrice.new(*row_with_types)
      end
    end

    def dividends(symbol, options={})
      splits_and_dividends(symbol, options)[1]
    end

    def splits(symbol, options={})
      splits_and_dividends(symbol, options)[0]
    end

    private
    def splits_and_dividends(symbol, options={})
      # Yahoo dividends are split adjusted so we have to unadjust them manually
      # Hence this bastard hybrid method

      start_date = options[:start_date]
      end_date = options[:end_date] || Date.today

      # Yahoo, what the hell is 'x' or g=v?
      response = raw_ichart_request(symbol, start_date: start_date, params: {g: 'v'}, resource: 'x')

      rows = CSV.parse(response)
      splits = []
      dividends = []
      dividend_adjustment = Rational(1)
      # rows[0] is the column name to some other response.  Yay Yahoo!
      rows[1..-1].each do |row|
        case row[0].downcase
          when 'split'
            type, date, value = row
            date = Date.strptime(date.strip, '%Y%m%d')
            after, before = value.split(':').map(&:to_i)
            dividend_adjustment = dividend_adjustment * after / before
            if date <= end_date
              splits << Split.new(date, before, after)
            end
          when 'dividend'
            type, date, amount = row
            date = Date.strptime(date.strip(), '%Y%m%d')
            amount = BigDecimal.new(amount) * dividend_adjustment
            if date <= end_date
              dividends << Dividend.new(date, amount)
            end
          else
            # There are quite a few metadata rows
        end
      end
      [splits, dividends]
    end

    def raw_ichart_request(symbol, options={})
      start_date = options[:start_date]
      end_date = options[:end_date]
      resource = options[:resource]
      params = options[:params] || {}

      params[:s] = symbol
      # Yahoo API is really terrible... abcdef go!
      if start_date
        # POSIX months...
        params[:a] = (start_date.month - 1)
        params[:b] = (start_date.day)
        params[:c] = (start_date.year)
      end
      if end_date
        params[:d] = (end_date.month - 1)
        params[:e] = (end_date.day)
        params[:f] = (end_date.year)
      end

      RestClient.get("http://ichart.finance.yahoo.com/#{resource}", params: params)
    end
  end
end
