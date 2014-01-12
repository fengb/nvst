class GenerateOwnershipsJob
  class << self
    def perform
      objects_needing_processing.sort_by{|o| [o.date, o.created_at]}.each do |o|
        o.generate_ownerships!
      end
    end

    private
    def objects_needing_processing
      GenerateOwnerships.models_included.map(&:all).flatten
    end
  end
end
