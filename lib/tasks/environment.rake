task :environment do
  if Rails.env != 'production' && !File.exists?(Figaro.application.path)
    rm_f Figaro.application.path
    symlink "#{Figaro.application.path}.dev", Figaro.application.path
  end
end
