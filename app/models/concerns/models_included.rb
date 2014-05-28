module ModelsIncluded
  def models_included
    RailsUtil.all(:models).select{|m| m.included_modules.include?(self)}
  end
end
