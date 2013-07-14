module DynamicSitemaps
  class SitemapGenerator
    attr_reader :sitemap
    attr_writer :counter, :page

    def initialize(sitemap)
      unless self.class.included_modules.include?(Rails.application.routes.url_helpers)
        self.class.send :include, Rails.application.routes.url_helpers
      end
      @sitemap = sitemap
    end

    def generate
      ensure_host!
      write_beginning
      write_urls
      write_end
      
      file.close
      
      SitemapResult.new(sitemap, files)
    end

    def write_beginning
      write '<?xml version="1.0" encoding="UTF-8"?>',
            '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    end

    def write_urls
      if sitemap.collection
        handle_collection
      else
        instance_eval &sitemap.block
      end
    end

    def write_url(url, options = {})
      write '<url>'
      write '<loc>' + format_url(url) + '</loc>'
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

    def write(*lines)
      file.puts lines
    end

    def handle_collection
      sitemap.collection.find_each do |record|
        if sitemap.block
          instance_exec record, &sitemap.block
        else
          url record, last_mod: (record.respond_to?(:updated_at) ? record.updated_at : nil)
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
      sitemap.name.to_s + (page > 1 ? page.to_s : "") + ".xml"
    end

    def folder
      sitemap.folder
    end

    def folder_path
      "#{DynamicSitemaps.temp_path}/#{folder}"
    end

    def path
      "#{folder_path}/#{file_name}"
    end

    def host
      sitemap.host
    end

    def ensure_host!
      raise "No host specified. Please specify a host using `host \"www.mydomain.com\"` at the top of your sitemap configuration file." if sitemap.host.blank?
    end

    def file
      @file ||= begin
        files << file_name
        FileUtils.mkdir_p folder_path
        File.open(path, "w")
      end
    end

    def files
      @files ||= []
    end

    def next_page
      write_end
      reset_counter
      file.close
      @file = nil
      self.page += 1
      write_beginning
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
        date.to_datetime.utc.strftime("%Y-%m-%dT%H:%M:%S%:z")
      end
    end
  end
end