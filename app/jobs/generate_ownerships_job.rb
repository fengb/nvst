class GenerateOwnershipsJob < ActiveJob::Base
  def perform
    self.class.objects_needing_processing.each do |o|
      o.generate_ownerships!
    end
  end

  def reset!
    SqlUtil.execute 'TRUNCATE ownerships RESTART IDENTITY CASCADE'
  end

  def self.classes_needing_processing
    RailsUtil.all(:models).select{|m| m.method_defined?(:generate_ownerships!)}
  end

  def self.objects_needing_processing
    classes_needing_processing.flat_map(&:all).sort_by do |o|
      [o.date, o.try(:created_at) || Date.current]
    end
  end
end
