Nvst::Application.configure do
  config.assets.version = '1.0'
  config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')
  config.assets.precompile += %w[
  ]
end
