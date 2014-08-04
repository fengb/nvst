INSERT INTO users(email,   encrypted_password, is_fee_collector)
           VALUES('admin', '',                 true);

INSERT INTO investments(symbol, name,               type)
                 VALUES('USD',  'U.S. Dollars',     'Investment::Cash'),
                       ('SPY',  'SPDR S&P 500 ETF', 'Investment::Stock');
