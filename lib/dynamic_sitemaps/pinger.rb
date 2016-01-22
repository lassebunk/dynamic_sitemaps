module DynamicSitemaps
  class Pinger
    class << self
      def ping_search_engines_with(sitemap_urls)
        sitemap_urls = [sitemap_urls] unless sitemap_urls.is_a?(Array)

        if sitemap_urls.any? && ping_for_environment?(Rails.env)
          Logger.info "Pinging search engines..."

          sitemap_urls.each do |url|
            ping_search_engines_with_sitemap_url url
          end

          Logger.info "Done pinging search engines."
        end
      end

      def ping_search_engines_with_sitemap_url(sitemap_url)
        sitemap_url = CGI::escape(sitemap_url)
        DynamicSitemaps.search_engine_ping_urls.each do |ping_url|
          url = ping_url % sitemap_url
          ping url
        end
      end

      def ping(url)
        Logger.info "Pinging #{url} ..."
        uri = URI.parse(url)
        begin
          Net::HTTP.new(
            uri.host,
            uri.port,
            DynamicSitemaps.proxy_host,
            DynamicSitemaps.proxy_port
          ).start do |http|
            http.get(uri.request_uri)
          end
        rescue Exception => e
          Logger.warn "Failed to ping #{url} : #{e}"
        end
      end

      def ping_for_environment?(env)
        DynamicSitemaps.ping_environments.map(&:to_s).include?(env.to_s)
      end
    end
  end
end
