require 'rails_helper'

RSpec.describe 'Spider', type: :request, order: :defined do
  url = TestServer.start

  context '/' do
    SpidrRSpec.test(context, url + '/')
  end

  context '/admin' do
    SpidrRSpec.test(context, url + '/admin')
  end
end
