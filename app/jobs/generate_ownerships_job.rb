class GenerateOwnershipsJob
  class << self
    def perform
      objects_needing_processing.sort_by{|o| [o.date, o.created_at]}.each do |o|
        o.generate_ownerships!
      end
    end

    private
    def models_needing_processing
      [].tap do |ret|
        ActiveRecord::Base.connection.tables.each do |table|
          str = table.singularize.camelize
          begin
            klass = str.constantize
          rescue NameError
            next
          end

          ret << klass if klass.method_defined?(:generate_ownerships!)
        end
      end
    end

    def objects_needing_processing
      models_needing_processing.map do |model|
        model.all
      end.flatten
    end
  end
end
