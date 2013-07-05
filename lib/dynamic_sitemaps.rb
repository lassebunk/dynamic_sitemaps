require "dynamic_sitemaps/rails/engine"
require "dynamic_sitemaps/sitemap"
require "dynamic_sitemaps/generator"
require "dynamic_sitemaps/sitemap_generator"

module DynamicSitemaps
  DEFAULT_PER_PAGE = 50_000

  class << self
    def generate_sitemap
      DynamicSitemaps::Generator.generate
    end

    def path
      @path ||= Rails.root.join("public", "sitemaps")
    end

    attr_writer :path
  end
end