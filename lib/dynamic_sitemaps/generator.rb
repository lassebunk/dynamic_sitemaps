module DynamicSitemaps
  class Generator
    # Generates the sitemap(s) and index based on the configuration file specified in DynamicSitemaps.config_path.
    # If you supply a block, that block is evaluated instead of the configuration file.
    def generate(&block)
      create_temp_dir
      if block
        instance_eval &block
      else
        instance_eval open(DynamicSitemaps.config_path).read, DynamicSitemaps.config_path
      end
      generate_index
      move_to_destination
      ping_search_engines
    ensure
      remove_temp_dir
    end

    def generate_index
      IndexGenerator.new(sitemaps).generate
    end

    def create_temp_dir
      remove_temp_dir
      FileUtils.mkdir_p DynamicSitemaps.temp_path
    end

    def remove_temp_dir
      FileUtils.rm_rf DynamicSitemaps.temp_path
    end

    def move_to_destination
      sitemaps.map(&:folder).uniq.each do |folder|
        destination = File.join(DynamicSitemaps.path, folder)
        FileUtils.mkdir_p destination
        FileUtils.rm_rf Dir.glob(File.join(destination, "*"))

        temp_files = File.join(DynamicSitemaps.temp_path, folder, "*.xml")
        FileUtils.mv Dir.glob(temp_files), destination
      end
      remove_temp_dir
    end

    def ping_search_engines
      Pinger.ping_search_engines_with ping_urls
    end

    def sitemap(*args, &block)
      args << {} unless args.last.is_a?(Hash)
      args.last[:host] ||= host
      args.last[:protocol] ||= protocol
      args.last[:folder] ||= folder
      sitemap = Sitemap.new(*args, &block)

      ensure_valid_sitemap_name! sitemap
      sitemap_names[sitemap.folder] << sitemap.name

      sitemaps << SitemapGenerator.new(sitemap).generate
    end

    def sitemap_for(collection, options = {}, &block)
      raise ArgumentError, "The collection given to `sitemap_for` must respond to #find_each. This is for performance. Use `Model.scoped` to get an ActiveRecord relation that responds to #find_each." unless collection.respond_to?(:find_each)

      name = options.delete(:name) || collection.model_name.to_s.underscore.pluralize.to_sym
      options[:collection] = collection

      sitemap(name, options, &block)
    end

    def ensure_valid_sitemap_name!(sitemap)
      raise ArgumentError, "Sitemap name :#{sitemap.name} has already been defined for the folder \"#{sitemap.folder}\". Please use `sitemap :other_name do ... end` or `sitemap_for <relation>, name: :other_name`." if sitemap_names[sitemap.folder].include?(sitemap.name)
      raise ArgumentError, "Sitemap name :#{sitemap.name} conflicts with the index file name #{DynamicSitemaps.index_file_name}. Please change it using `sitemap :other_name do ... end`." if "#{sitemap.name}.xml" == DynamicSitemaps.index_file_name
    end

    # Array of SitemapResult
    def sitemaps
      @sitemaps ||= []
    end

    # Generated sitemap names
    def sitemap_names
      @sitemap_names ||= Hash.new { |h, k| h[k] = [] }
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

    def protocol(*args)
      if args.any?
        @protocol = args.first
        Rails.application.routes.default_url_options[:protocol] = @protocol
      else
        @protocol
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
      else
        # Ensure that the default folder is set and cleaned.
        folder DynamicSitemaps.folder if @folder.blank?

        @folder
      end
    end
  end
end