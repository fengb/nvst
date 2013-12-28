class Expense < ActiveRecord::Base
  has_and_belongs_to_many :transactions
end
