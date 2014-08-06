class GenerateOwnershipsJob
  class << self
    def perform
      objects_needing_processing.each do |o|
        o.generate_ownerships!
      end
    end

    def delete!
      ActiveRecord::Base.connection.execute 'TRUNCATE ownerships RESTART IDENTITY CASCADE'
    end

    private
    def classes_needing_processing
      RailsUtil.all(:models).select{|m| m.method_defined?(:generate_ownerships!)}
    end

    def objects_needing_processing
      classes_needing_processing.map(&:all).flatten.sort_by do |o|
        [o.date, o.try(:created_at) || Date.today]
      end
    end
  end
end
