require "dynamic_sitemaps/rails/engine"
require "dynamic_sitemaps/sitemap"
require "dynamic_sitemaps/generator"
require "dynamic_sitemaps/sitemap_generator"
require "dynamic_sitemaps/index_generator"
require "dynamic_sitemaps/sitemap_result"
require "dynamic_sitemaps/pinger"

module DynamicSitemaps
  DEFAULT_PER_PAGE = 50000
  DEFAULT_FOLDER = "sitemaps"
  DEFAULT_INDEX_FILE_NAME = "sitemap.xml"
  DEFAULT_ALWAYS_GENERATE_INDEX = false
  SEARCH_ENGINE_PING_URLS = [
    "http://www.google.com/webmasters/sitemaps/ping?sitemap=%s",
    "http://www.bing.com/webmaster/ping.aspx?siteMap=%s"
  ]

  class << self
    attr_writer :path, :folder, :index_file_name, :always_generate_index, :config_path, :search_engine_ping_urls

    def generate_sitemap
      DynamicSitemaps::Generator.generate
    end

    # Configure DynamicSitemaps.
    # Defaults:
    # 
    #   DynamicSitemaps.configure do |config|
    #     config.path = Rails.root.join("public")
    #     config.folder = "sitemaps"
    #     config.index_file_name = "sitemap.xml"
    #     config.always_generate_index = false
    #     config.config_path = Rails.root.join("config", "sitemap.rb")
    #   end
    # 
    # To ping search engines after generating the sitemap:
    # 
    #   DynamicSitemaps.configure do |config|
    #     config.search_engine_ping_urls << "http://customsearchengine.com/ping?url=%s" # Default is Google and Bing
    #     config.sitemap_ping_urls = ["http://www.domain.com/sitemap.xml"]
    #     # or dynamically:
    #     config.sitemap_ping_urls = -> { Site.all.map { |site| "http://#{site.domain}/sitemap.xml" } }
    #   end
    def configure
      yield self
    end

    def folder
      @folder ||= DEFAULT_FOLDER
    end

    def path
      @path ||= Rails.root.join("public")
    end

    def index_file_name
      @index_file_name ||= DEFAULT_INDEX_FILE_NAME
    end

    def always_generate_index
      return @always_generate_index if instance_variable_defined?(:@always_generate_index)
      @always_generate_index = DEFAULT_ALWAYS_GENERATE_INDEX
    end

    def config_path
      @config_path ||= Rails.root.join("config", "sitemap.rb")
    end

    def search_engine_ping_urls
      @search_engine_ping_urls ||= SEARCH_ENGINE_PING_URLS
    end

    def sitemap_ping_urls
      case @sitemap_ping_urls
      when Array then @sitemap_ping_urls
      when Proc then @sitemap_ping_urls.call
      else []
      end
    end

    def sitemap_ping_urls=(array_or_proc)
      unless array_or_proc.is_a?(Array) || array_or_proc.is_a?(Proc)
        raise "Unknown type #{array_or_proc.class.name} for sitemap_ping_urls."
      end
      @sitemap_ping_urls = array_or_proc
    end

    # Resets all instance variables. Used for testing.
    def reset!
      instance_variables.each { |var| remove_instance_variable var }
    end
  end
end