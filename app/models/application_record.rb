class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def has_attributes?(attrs)
    attrs.all? { |(key, value)| has_attribute?(key, value) }
  end
end
