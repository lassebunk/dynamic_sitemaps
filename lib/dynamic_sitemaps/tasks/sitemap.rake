namespace :sitemap do
  task :generate => :environment do
    start_time = Time.now
    puts "Generating sitemap..."
    DynamicSitemaps.generate_sitemap
    puts "Done generating sitemap in #{Time.now - start_time} seconds."

    if Rails.env.production?
      DynamicSitemaps::Pinger.ping_search_engines
    end
  end
end