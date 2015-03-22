require 'spidr'

module SpidrRSpec
  def self.test(context, url, *args)
    Spidr.site(url) do |spidr|
      yield spidr if block_given?

      spidr.every_page do |page|
        context.specify page.url.path do
          if page.response.code.to_i >= 500
            raise page.body
          end
        end
      end

      spidr.every_failed_url do |url|
        context.specify url do
          fail "failed to connect to #{url}"
        end
      end
    end
  end
end
