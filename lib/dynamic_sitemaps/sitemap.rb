module DynamicSitemaps
  class Sitemap
    attr_reader :name, :collection, :block, :host, :folder, :protocol, :proxy_host, :proxy_port

    # Initializes a sitemap object.
    # 
    #   Sitemap.new(:site) do
    #     url root_url
    #   end
    def initialize(*args, &block)
      if args.first.is_a?(Symbol)
        @name = args.shift
      end

      if args.last.is_a?(Hash)
        options = args.pop
        @per_page = options[:per_page]
        @protocol = options[:protocol]
        @host = options[:host]
        @folder = options[:folder]
        @collection = options[:collection]
        @proxy_host = options[:proxy_host]
        @proxy_port = options[:proxy_port]
      end

      @block = block
    end

    def root_url
      "#{protocol}://#{host}"
    end

    def per_page
      @per_page ||= DynamicSitemaps.per_page
    end

    def protocol
      @protocol ||= DynamicSitemaps.protocol
    end

    # Generates sitemap XML files based on this sitemap
    def generate
    end
  end
end
