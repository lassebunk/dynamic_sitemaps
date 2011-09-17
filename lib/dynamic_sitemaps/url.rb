module DynamicSitemaps
  class Url
    attr_accessor :loc, :last_mod, :change_freq, :priority
    
    def initialize(loc, options = {})
      @loc, @last_mod, @change_freq, @priority = loc, options[:last_mod], options[:change_freq], options[:priority]
    end
  end
end