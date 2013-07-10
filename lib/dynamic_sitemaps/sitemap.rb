module DynamicSitemaps
  class Sitemap
    attr_reader :name, :collection, :block, :host, :folder

    # Initializes a sitemap object.
    # 
    #   Sitemap.new(:site) do
    #     url root_url
    #   end
    # 
    # Using an ActiveRecord relation:
    # 
    #   Sitemap.new(:site, Product.visible) do |product|
    #     url product
    #     url product_editions_path(product)
    #   end
    
    def initialize(*args, &block)
      if args.first.is_a?(Symbol)
        @name = args.shift
      end

      if args.last.is_a?(Hash)
        options = args.pop
        @per_page = options[:per_page]
        @host = options[:host]
        @folder = options[:folder]
        @collection = options[:collection]
      end

      @block = block
    end

    def root_url
      "http://#{host}"
    end

    def per_page
      @per_page ||= DynamicSitemaps.per_page
    end

    # Generates sitemap XML files based on this sitemap
    def generate
    end
  end
end