require "dynamic_sitemaps/rails/engine"
require "dynamic_sitemaps/sitemap"
require "dynamic_sitemaps/generator"
require "dynamic_sitemaps/sitemap_generator"
require "dynamic_sitemaps/index_generator"
require "dynamic_sitemaps/sitemap_result"
require "dynamic_sitemaps/pinger"
require "dynamic_sitemaps/logger"

module DynamicSitemaps
  DEFAULT_PER_PAGE = 50000
  DEFAULT_FOLDER = "sitemaps"
  DEFAULT_INDEX_FILE_NAME = "sitemap.xml"
  DEFAULT_ALWAYS_GENERATE_INDEX = false
  DEFAULT_PROTOCOL = "http"
  SEARCH_ENGINE_PING_URLS = [
    "http://www.google.com/webmasters/sitemaps/ping?sitemap=%s",
    "http://www.bing.com/webmaster/ping.aspx?siteMap=%s"
  ]
  DEFAULT_PING_ENVIRONMENTS = ["production"]

  class << self
    attr_writer :index_file_name, :always_generate_index, :per_page, :search_engine_ping_urls, :ping_environments

    # Generates the sitemap(s) and index based on the configuration file specified in DynamicSitemaps.config_path.
    # If you supply a block, that block is evaluated instead of the configuration file.
    def generate_sitemap(&block)
      DynamicSitemaps::Generator.new.generate(&block)
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
    #     config.per_page = 50_000
    #   end
    # 
    # To ping search engines after generating the sitemap:
    # 
    #   DynamicSitemaps.configure do |config|
    #     config.search_engine_ping_urls << "http://customsearchengine.com/ping?url=%s" # Default is Google and Bing
    #     config.ping_environments << "staging" # Default is production
    #   end
    def configure
      yield self
    end

    def folder
      @folder ||= DEFAULT_FOLDER
    end

    def folder=(new_folder)
      raise ArgumentError, "DynamicSitemaps.folder can't be blank." if new_folder.blank?
      @folder = new_folder
    end

    def path
      @path ||= Rails.root.join("public").to_s
    end

    def path=(new_path)
      raise ArgumentError, "DynamicSitemaps.path can't be blank." if new_path.blank?
      @path = new_path.to_s
    end

    def index_file_name
      @index_file_name ||= DEFAULT_INDEX_FILE_NAME
    end

    def always_generate_index
      return @always_generate_index if instance_variable_defined?(:@always_generate_index)
      @always_generate_index = DEFAULT_ALWAYS_GENERATE_INDEX
    end

    def config_path
      @config_path ||= Rails.root.join("config", "sitemap.rb").to_s
    end

    def config_path=(new_path)
      raise ArgumentError, "DynamicSitemaps.config_path can't be blank." if new_path.blank?
      @config_path = new_path.to_s
    end

    def per_page
      @per_page ||= DEFAULT_PER_PAGE
    end

    def search_engine_ping_urls
      @search_engine_ping_urls ||= SEARCH_ENGINE_PING_URLS.dup
    end

    def ping_environments
      @ping_environments ||= DEFAULT_PING_ENVIRONMENTS.dup
    end

    # Removed in version 2.0.0.beta2
    def sitemap_ping_urls=(array_or_proc)
      raise "sitemap_ping_urls has been removed. Please use `ping \"http://example.com/sitemap.xml\"` in config/sitemap.rb instead."
    end

    def temp_path
      @temp_path ||= Rails.root.join("tmp", "dynamic_sitemaps").to_s
    end

    def protocol
      @protocol ||= DEFAULT_PROTOCOL
    end

    # Resets all instance variables. Used for testing.
    def reset!
      instance_variables.each { |var| remove_instance_variable var }
    # reset the protocol to http
      Rails.application.routes.default_url_options[:protocol] = "http"
    end
  end
end