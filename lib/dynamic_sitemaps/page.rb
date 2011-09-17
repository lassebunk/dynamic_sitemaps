module DynamicSitemaps
  class Page
    def urls
      @urls ||= []
    end
    
    def last_mod
      mod = nil
      
      urls.each do |url|
        unless url.last_mod.nil?
          if mod.nil? || url.last_mod > mod
            mod = url.last_mod
          end
        end
      end
      
      mod
    end
  end
end