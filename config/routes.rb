DynamicSitemaps::Engine.routes.draw do
  get '*sitemaps', to: 'dynamic_sitemaps#sitemap'
end
