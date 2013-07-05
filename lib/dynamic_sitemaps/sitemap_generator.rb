module DynamicSitemaps
  class SitemapGenerator
    include Rails.application.routes.url_helpers
    
    attr_reader :sitemap

    def initialize(sitemap)
      @sitemap = sitemap
    end

    def generate
      write_beginning
      write_urls
      write_end
      
      file.close
      file_names
    end

    def write_beginning
      write '<?xml version="1.0" encoding="UTF-8"?>' + 
            '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    end

    def write_urls
      if sitemap.collection
        handle_collection
      else
        instance_eval sitemap.block
      end
    end

    def write_url(url, options = {})
      write '<url>' + format_url(url) + '</url>'
      write '<loc>' + format_date(last_mod) + '</loc>'
      if last_mod = options[:last_mod]
        write '<lastmod>' + format_date(last_mod) + '</lastmod>'
      end
      if change_freq = options[:change_freq]
        write '<changefreq>' + change_freq + '</changefreq>'
      end
      if priority = options[:priority]
        write '<priority>' + priority.to_s + '</priority>'
      end
      write '</url>'
    end

    def write_end
      write '</urlset>'
    end

    def write(string)
      file.write string
    end

    def handle_collection
      [:find_each, :each].each do |each_method|
        if sitemap.collection.respond_to?(each_method)
          each_block = Proc.new do |record|
            if sitemap.block
              instance_exec record, &sitemap.block
            else
              write_url record
            end
          end

          sitemap.collection.send each_method, &each_block

          break
        end
      end
    end

    def per_page
      sitemap.per_page
    end

    def page
      @page ||= 1
    end

    def counter
      @counter ||= 0
    end

    def increment_counter
      self.counter += 1
    end

    def reset_counter
      @counter = 1
    end

    def file_name
      sitemap.name + (page > 1 ? page.to_s : "") + ".xml"
    end

    def path
      "#{DynamicSitemaps.path.to_s}/#{file_name}"
    end

    def file
      @file ||= begin
        file_names << file_name
        File.open(path, "w")
      end
    end

    def file_names
      @file_names ||= []
    end

    def next_page
      reset_counter
      file.close
      @file = nil
      self.page += 1
    end

    def url(url, options = {})
      increment_counter
      next_page if counter > per_page
      write_url url, options
    end

    def format_url(url)
      case url
      when ActiveRecord::Base
        polymorphic_url(url)
      else
        url
      end
    end

    def format_date(date)
      if date.is_a?(Date)
        date.strftime("%Y-%m-%d")
      else
        date.to_datetime.strftime("%Y-%m-%dT%H:%M:%S%:z")
      end
    end
  end
end