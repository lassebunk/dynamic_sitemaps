module DynamicSitemaps
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    
    def create_config
      copy_file "config.rb", "config/sitemap.rb"
    end
  end
end