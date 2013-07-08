module DynamicSitemaps
  class Engine < Rails::Engine
    engine_name :dynamic_sitemaps

    rake_tasks do
      load "dynamic_sitemaps/tasks/sitemap.rake"
    end
  end
end