module GenerateOwnerships
  def generate_ownerships!
    return if ownerships.count > 0

    raw_ownerships_data.each do |data|
      ownerships.create!(data)
    end
  end

  def ownership_units(at: nil, amount: 1)
    # Assume all cashflows are incurred at once on the same day
    total_value = ownership_portfolio.value_at(at) - ownership_portfolio.cashflow_at(at)
    return 1 if total_value == 0

    # Assume all unit movement are incurred at once on the same day
    Ownership.total_at(at - 1) / total_value * amount
  end

  def ownership_portfolio
    @ownership_portfolio ||= PortfolioPresenter.all
  end
end
