module DynamicSitemaps
  class Generator
    # Generates the sitemap(s) and index based on the configuration file specified in DynamicSitemaps.config_path.
    # If you supply a block, that block is evaluated instead of the configuration file.
    def generate(&block)
      if block
        instance_eval &block
      else
        instance_eval open(DynamicSitemaps.config_path).read
      end
      generate_index
      ping_search_engines
    end

    def generate_index
      IndexGenerator.new(sitemaps).generate
    end

    def ping_search_engines
      Pinger.ping_search_engines_with ping_urls
    end

    def sitemap(*args, &block)
      args << {} unless args.last.is_a?(Hash)
      args.last[:host] ||= host
      args.last[:folder] ||= folder
      sitemap = Sitemap.new(*args, &block)
      sitemaps << SitemapGenerator.new(sitemap).generate
    end

    def sitemap_for(collection, options = {}, &block)
      raise ArgumentError, "The collection given to `sitemap_for` must respond to #find_each. This is for performance. Use `Model.scoped` to get an ActiveRecord relation that responds to #find_each." unless collection.respond_to?(:find_each)

      name = options.delete(:name) || collection.model_name.underscore.pluralize.to_sym
      options[:collection] = collection

      sitemap(name, options, &block)
    end

    # Array of SitemapResult
    def sitemaps
      @sitemaps ||= []
    end

    # URLs to ping after generation
    def ping_urls
      @ping_urls ||= []
    end

    def host(*args)
      if args.any?
        @host = args.first
        Rails.application.routes.default_url_options[:host] = @host
      else
        @host
      end
    end

    # Adds a sitemap URL to ping search engines with after generation.
    def ping_with(sitemap_url)
      ping_urls << sitemap_url
    end

    def folder(*args)
      if args.any?
        @folder = args.first
        raise ArgumentError, "Folder can't be blank." if @folder.blank?

        FileUtils.rm_rf Dir.glob("#{DynamicSitemaps.path}/#{folder}/*")
      else
        # Ensure that the default folder is set and cleaned.
        folder DynamicSitemaps.folder if @folder.blank?

        @folder
      end
    end
  end
end