Eye.load './eye/*.rb'

config_file = File.expand_path('../../.eye', __FILE__)
configs = IO.read(config_file).split
Eye::Bitvain.start_with(*configs)
