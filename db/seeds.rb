path = File.dirname(__FILE__)
connection = ActiveRecord::Base.connection
statements = IO.read(path + '/seeds.sql').split(';').map(&:strip).reject(&:empty?)

ActiveRecord::Base.transaction do
  statements.each do |statement|
    connection.execute(statement)
  end
end
