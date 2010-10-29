class SitemapsController < ApplicationController
  def sitemap
    new_page!
    instance_eval &Sitemap::Map.draw_block
    
    if params[:page]
      if pages.count > 1
        page = pages[params[:page].to_i - 1]

        if page
          @urls = page.urls
        else
          @urls = []
        end
      else
        @urls = []
      end
    elsif pages.count > 1
      @pages = pages
      render :index
    else
      @urls = pages.last.urls
    end
  end
  
protected
  
  def pages
    @pages ||= []
  end
  
  def new_page!
    pages << Sitemap::Page.new
  end
  
  def current_page
    pages.last
  end
  
  def per_page!(size = nil)
    @per_page = size
  end
  
  def per_page
    @per_page ||= 50000
  end
  
  def url(loc, options = {})
    if current_page.urls.count >= per_page
      new_page!
    end
    
    loc = url_for(loc) unless loc.is_a?(String)
    
    current_page.urls << Sitemap::Url.new(loc, options)
  end
  
  def autogenerate(*args)
    options = args.extract_options!
    
    args.flatten.each do |sym|
      sym.to_s.singularize.camelize.constantize.send(:all).each do |obj|
        url obj, convert_options(options, obj)
      end
    end
  end
  
  def convert_options(options, obj)
    options.each do |key, value|
      if value.is_a?(Symbol)
        value = obj.send(value)
      elsif value.is_a?(Proc)
        value = value.call(obj)
      end
      options[key] = value
    end
    options
  end
  
end













