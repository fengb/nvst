INSERT INTO investments(symbol, name,               category)
                 VALUES('USD',  'U.S. Dollars',     'cash'),
                       ('SPY',  'SPDR S&P 500 ETF', 'benchmark');

INSERT INTO investment_historical_prices(investment_id,         date, high, low, close, raw_adjustment)
                                  SELECT id,            '1900-01-01',    1,   1,     1,              1
                                    FROM investments
                                   WHERE symbol='USD';
