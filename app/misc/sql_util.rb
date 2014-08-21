module SqlUtil
  def self.sanitize(sql, *args)
    ActiveRecord::Base.send(:sanitize_sql_array, [sql, *args])
  end

  def self.execute(sql, *args)
    if args.present?
      sql = sanitize(sql, *args)
    end
    ActiveRecord::Base.connection.execute(sql)
  end
end
