class DynamicSitemapsGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  
  def create_initializer
    copy_file "initializer.rb", "config/initializers/sitemap.rb"
  end

  def create_route
    route "match '#{file_name}' => 'sitemaps#sitemap'"
  end
end
