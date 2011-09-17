class DynamicSitemapsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  def create_initializer
    copy_file "initializer.rb", "config/initializers/#{file_name}.rb"
  end

  def create_route
    route "match 'sitemap.xml' => 'sitemaps#sitemap'"
  end
end
