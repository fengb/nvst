module ModelsIncluded
  def models_included
    all_models.select{|m| m.included_modules.include?(self)}
  end

  private
  def all_models
    Dir[Rails.root + 'app/models/*'].map{|f| File.basename f, '.rb'}.map{|m| m.camelize.constantize}
  end
end
