require 'rails_helper'

RSpec.describe 'Spider', type: :request do
  url = TestServer.start

  Spidr.site(url) do |spider|
    spider.every_page do |page|
      specify page.url do
        if page.response.code.to_i >= 500
          raise page.body
        end
      end
    end

    spider.every_failed_url do |url|
      specify url do
        fail 'failed to connect'
      end
    end
  end
end
