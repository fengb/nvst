Eye.load './eye/*.rb'
Eye::Nvst.start_with(*ENV.fetch('NVST_EYE').split)
