namespace :sitemap do
  task :generate => :environment do
    start_time = Time.now
    DynamicSitemaps::Logger.info "Generating sitemap..."
    DynamicSitemaps.generate_sitemap
    DynamicSitemaps::Logger.info "Done generating sitemap in #{Time.now - start_time} seconds."
  end
end