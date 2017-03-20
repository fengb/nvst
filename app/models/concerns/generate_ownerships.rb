module GenerateOwnerships
  def generate_ownerships!
    return if ownerships.count > 0

    raw_ownerships_data.each do |data|
      ownerships.create!(data)
    end
  end

  def ownership_units(on:, amount: 1, cashflow: true)
    # Assume all unit movement are incurred at once on the same day
    total_units = Ownership.total_on(on - 1)
    return amount if total_units == 0

    # Assume all cashflows are incurred at once on the same day
    total_value = ownership_portfolio.value_on(on) - ownership_portfolio.cashflow_on(on)
    total_value -= amount unless cashflow

    total_units / total_value * amount
  end

  def ownership_portfolio
    @ownership_portfolio ||= PortfolioPresenter.all
  end
end
