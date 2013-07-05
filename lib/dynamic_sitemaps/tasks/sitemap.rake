namespace :sitemap do
  task :generate => :environment do
    Rails.logger.info "Generating sitemap..."
    DynamicSitemaps.generate_sitemap
    Rails.logger.info "Done generating sitemap."
  end
end