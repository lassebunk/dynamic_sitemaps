require "dynamic_sitemaps/rails/engine"
require "dynamic_sitemaps/sitemap"
require "dynamic_sitemaps/generator"
require "dynamic_sitemaps/sitemap_generator"
require "dynamic_sitemaps/sitemap_result"

module DynamicSitemaps
  DEFAULT_PER_PAGE = 2
  DEFAULT_FOLDER = "sitemaps"

  class << self
    attr_writer :path, :relative_path, :folder, :config_path

    def generate_sitemap
      DynamicSitemaps::Generator.generate
    end

    # Configure DynamicSitemaps.
    # 
    #   DynamicSitemaps.configure do |config|
    #     config.path = "/my/sitemaps/folder"
    #     config.config_path = Rails.root.join("config", "custom", "sitemap.rb")
    #     config.relative_path = "/custom-folder/sitemaps"
    def configure
      yield self
    end

    def folder
      @folder ||= DEFAULT_FOLDER
    end

    def path
      @path ||= Rails.root.join("public")
    end

    def config_path
      @config_path ||= Rails.root.join("config", "sitemap.rb")
    end
  end
end