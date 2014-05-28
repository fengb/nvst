module RailsUtil
  def self.all(dir)
    Dir[Rails.root + "app/#{dir}/*"].map{|f| File.basename f, '.rb'}.map{|m| m.camelize.constantize}
  end
end
