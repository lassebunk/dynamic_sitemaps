require "dynamic_sitemaps/rails/engine"
require "dynamic_sitemaps/sitemap"
require "dynamic_sitemaps/generator"
require "dynamic_sitemaps/sitemap_generator"
require "dynamic_sitemaps/index_generator"
require "dynamic_sitemaps/sitemap_result"

module DynamicSitemaps
  DEFAULT_PER_PAGE = 1000
  DEFAULT_FOLDER = "sitemaps"
  DEFAULT_INDEX_FILE_NAME = "sitemap.xml"
  DEFAULT_ALWAYS_GENERATE_INDEX = false

  class << self
    attr_writer :path, :folder, :index_file_name, :always_generate_index, :config_path

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
  end
end