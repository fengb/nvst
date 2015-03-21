require 'rails_helper'

RSpec.describe 'Spider', type: :request, order: :defined do
  url = TestServer.start
  SpidrRSpec.test(context, url + '/')
end
