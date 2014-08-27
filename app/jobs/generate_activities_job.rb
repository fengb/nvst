class GenerateActivitiesJob
  class << self
    def perform
      objects_needing_processing.each do |o|
        o.generate_activities!
      end
    end

    def reset!
      # This really doesn't belong here...
      SqlUtil.execute <<-END
        TRUNCATE positions RESTART IDENTITY CASCADE;
        DELETE FROM activity_adjustments;
      END
    end

    def classes_needing_processing
      RailsUtil.all(:models).select{|m| m.method_defined?(:generate_activities!)}
    end

    def objects_needing_processing
      classes_needing_processing.map(&:all).flatten.sort_by do |o|
        [o.date, priority(o), o.try(:created_at) || Date.today]
      end
    end

    def priority(obj)
      case obj.class
        when InvestmentSplit then -100
        when Contribution    then  -10
        else                         0
      end
    end
  end
end
