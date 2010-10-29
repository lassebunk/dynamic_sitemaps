module Sitemap
  class Url
    attr_accessor :loc, :last_mod, :change_freq, :priority
    
    def initialize(loc, options = {})
      @loc, @last_mod, @change_freq, @priority = loc, options[:last_mod], options[:change_freq], options[:priority]
    end

    def convert_option(option, obj = nil)
      if option.is_a?(Symbol) && !obj.nil?
        option = obj.send(option)
      elsif option.is_a?(Proc)
        option = option.call(obj)
      end
      option
    end
  end
end