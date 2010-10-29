module Sitemap
  class Page
    def urls
      @urls ||= []
    end
    
    def last_mod
      # TODO: Retrieve last date from urls
      DateTime.now # urls.max { |a, b| a.last_mod <=> b.last_mod }
    end
  end
end