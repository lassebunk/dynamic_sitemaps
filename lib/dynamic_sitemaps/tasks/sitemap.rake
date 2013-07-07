namespace :sitemap do
  task :generate => :environment do
    start_time = Time.now
    puts "Generating sitemap..."
    DynamicSitemaps.generate_sitemap
    puts "Done generating sitemap in #{Time.now - start_time} seconds."

    if Rails.env.production?
      sitemap_urls = DynamicSitemaps.sitemap_ping_urls
      if sitemap_urls.any?
        puts "Pinging search engines..."

        sitemap_urls.each do |sitemap_url|
          sitemap_url = CGI::escape(sitemap_url)
          DynamicSitemaps.search_engine_ping_urls.each do |ping_url|
            url = ping_url % sitemap_url
            puts "Pinging #{url} ..."

            begin
              Net::HTTP.get(URI.parse(url))
            rescue Exception => e
              puts "Failed to ping #{url} : #{e}"
            end
          end
        end

        puts "Done pinging search engines."
      end
    end
  end
end