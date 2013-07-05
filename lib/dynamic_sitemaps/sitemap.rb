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
    def initialize(*args, &block)
      if args.first.is_a?(Symbol)
        @name = args.shift
      end

      if args.first.is_a?(ActiveRecord::Relation)
        @collection = args.shift
        @name ||= @collection.table_name
      end

      if args.last.is_a?(Hash)
        options = args.pop
        @per_page = options[:per_page]
      end

      @block = block
    end

    def per_page
      @per_page ||= DynamicSitemaps::DEFAULT_PER_PAGE
    end

    # Generates sitemap XML files based on this sitemap
    def generate
    end
  end
end