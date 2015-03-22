require 'rails_helper'

RSpec.describe 'Spider', type: :request, order: :defined do
  url = TestServer.start

  context '/' do
    SpidrRSpec.test(context, url + '/')
  end

  context '/admin' do
    admin = FactoryGirl.create(:admin, password: 'password')
    SpidrRSpec.test(context, url + '/admin') do |spidr|
      params = "admin[username]=#{admin.username}&admin[password]=#{admin.password}"
      spidr.post_page(url + '/admin/sign_in', params)
    end
  end
end
