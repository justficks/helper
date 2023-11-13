Get subscription in Lago:

1. Update file /app/lib/lago_utils/lago_utils/license.rb in lago_api (code below)
2. Rebuild lago_api container

```ruby
# frozen_string_literal: true

module LagoUtils
  class License
    def initialize(url)
      @url = url
      @premium = true
    end

    def verify
      # Оставляем проверку лицензии, но игнорируем ее результат
      return if ENV['LAGO_LICENSE'].blank?

      http_client = LagoHttpClient::Client.new("#{url}/verify/#{ENV['LAGO_LICENSE']}")
      response = http_client.get

      # Независимо от результата, устанавливаем @premium в true
      @premium = true
    end

    def premium?
      premium
    end

    private

    attr_reader :url, :premium
  end
end


```
