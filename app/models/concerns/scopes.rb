module Scopes
  module Year
    extend ActiveSupport::Concern
    included do
      scope :year, ->(year){where('EXTRACT(year FROM date) = ?', year)}
    end
  end
end
