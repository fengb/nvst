module TaxDocs
  class Form1065Presenter
    def initialize(year)
      @year = year
    end

    def expense_categories
      Expense.categories.values
    end

    def expenses(category=nil)
      @expenses ||= Expense.year(@year).to_a
      category.nil? ? @expenses : @expenses.select{|e| e.category == category}
    end
  end
end
