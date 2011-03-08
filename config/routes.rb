Rails.application.routes.draw do
  match 'sitemap.xml' => 'sitemaps#sitemap'
end