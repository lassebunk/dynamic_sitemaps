# Contains the result of a sitemap generation

module DynamicSitemaps
  class SitemapResult
    attr_reader :sitemap, :files

    def initialize(sitemap, files)
      @sitemap = sitemap
      @files = files
    end

    def name
      sitemap.name
    end

    def host
      sitemap.host
    end

    def folder
      sitemap.folder
    end

    def protocol
      sitemap.protocol
    end

    def custom_path
      sitemap.custom_path
    end
  end
end