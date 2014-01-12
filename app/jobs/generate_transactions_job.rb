class GenerateTransactionsJob
  class << self
    def perform
      objects_needing_processing.sort_by{|o| [o.date, o.created_at]}.each do |o|
        o.generate_transactions!
      end
    end

    private
    def models_needing_processing
      GenerateTransactions.models_included
    end

    def objects_needing_processing
      models_needing_processing.map do |model|
        table = model.table_name
        join_table = model.reflections[:transactions].join_table
        ids = ActiveRecord::Base.connection.select_rows(<<-END).flatten
          SELECT t.id
            FROM #{table} t
            LEFT JOIN #{join_table} jt
                   ON jt.#{table.singularize}_id = t.id
           WHERE jt.id IS NULL
        END
        ids.empty? ? [] : model.find(ids)
      end.flatten
    end
  end
end
