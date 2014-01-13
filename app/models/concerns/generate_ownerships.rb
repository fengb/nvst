module GenerateOwnerships
  extend ModelsIncluded

  def generate_ownerships!
    return if ownerships.count > 0

    raw_ownerships_data.each do |data|
      ownerships.create!(data)
    end
  end
end
