task :environment do
  if Rails.env != 'production' && !File.exists?(Figaro.application.path)
    symlink("#{Figaro.application.path}.development", Figaro.application.path)
  end
end
