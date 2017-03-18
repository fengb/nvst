class GenerateActivitiesJob < ApplicationJob
  queue_as :default

  def perform
    self.class.objects_needing_processing.each do |o|
      o.generate_activities!
    end
  end

  def reset!
    # This really doesn't belong here...
    SqlUtil.execute <<-END
      TRUNCATE positions RESTART IDENTITY CASCADE;
      UPDATE investment_splits SET activity_adjustment_id=NULL;
      DELETE FROM activity_adjustments;
      ALTER SEQUENCE activity_adjustments_id_seq RESTART;
    END
  end

  def self.classes_needing_processing
    RailsUtil.all(:models).select{|m| m.method_defined?(:generate_activities!)}
  end

  def self.objects_needing_processing
    classes_needing_processing.flat_map(&:all).sort_by do |o|
      [o.date, priority(o), o.try(:created_at) || Date.current]
    end
  end

  def self.priority(obj)
    case obj.class
      when InvestmentSplit then -100
      when Contribution    then  -10
      else                         0
    end
  end
end
