class Event < ActiveRecord::Base
  belongs_to :src_investment, class_name: 'Investment'
end
