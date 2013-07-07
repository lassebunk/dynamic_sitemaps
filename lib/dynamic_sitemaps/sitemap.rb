module DynamicSitemaps
  class Sitemap
    attr_accessor :name, :collection, :block

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
    
    attr_reader :host, :folder

    def initialize(*args, &block)
      if args.first.is_a?(Symbol)
        @name = args.shift
      end

      if args.last.is_a?(Hash)
        options = args.pop
        @per_page = options[:per_page]
        @host = options[:host]
        @folder = options[:folder]
      end

      if args.first.respond_to?(:find_each) || args.first.respond_to?(:each)
        @collection = args.shift
        @name ||= begin
          @collection.table_name if @collection.respond_to?(:table_name)
        end
      end

      @block = block
    end

    def root_url
      "http://#{host}"
    end

    def per_page
      @per_page ||= DynamicSitemaps::DEFAULT_PER_PAGE
    end

    # Generates sitemap XML files based on this sitemap
    def generate
    end
  end
end