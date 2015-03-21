require 'spidr'

module SpidrRSpec
  def self.test(context, url, *args, &block)
    Spidr.site(url) do |spider|
      spider.every_page do |page|
        context.specify page.url do
          if page.response.code.to_i >= 500
            raise page.body
          end
        end
      end

      spider.every_failed_url do |url|
        context.specify url do
          fail "failed to connect to #{url}"
        end
      end
    end
  end
end
