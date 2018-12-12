require 'open-uri'

module YahooFinance
  BASE_URL = "https://finance.yahoo.com/quote"

  def self.history(symbol, **opts)
    open("#{BASE_URL}/#{symbol}/history?#{converted_params opts}") do |f|
      json = json_from_html(f.read)

      json&.dig('context', 'dispatcher', 'stores', 'HistoricalPriceStore').tap do |result|
        raise OpenURI::HTTPError.new("Cannot process #{symbol}", f) if result.nil?
      end
    end
  end

  def self.converted_params(start_date: nil, end_date: nil, **opts)
    if start_date
      opts[:period1] = start_date.to_datetime.to_i
      end_date ||= Date.today
    end

    if end_date
      opts[:period2] = end_date.to_datetime.to_i
    end

    opts.to_param
  end

  def self.json_from_html(html)
    json_string = html.sub(/.*root.App.main *= */m, '').sub(/\};$.*/m, '}')
    JSON.parse json_string
  end
end
