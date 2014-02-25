require 'rails/generators/active_record'

module DynamicSitemaps
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    STORAGES_AVAILABLE = [ :local, :aws, :database ]

    def create_config
      migration_template('create_sitemaps.rb', 'db/migrate/create_sitemaps.rb') if storage == :database

      copy_file "#{storage}_initializer.rb", 'config/dynamic_sitemaps.rb'
      copy_file 'config.rb', 'config/sitemap.rb'
    end

    def storage
      @storage ||= parse_storage
    end

    protected
    def self.next_migration_number(dirname)
      Time.now.strftime "%Y%m%d%H%M%S"
    end

    def parse_storage
      args.each do |arg|
        match = arg.match /storage\:/

        storage = match.post_match.downcase.to_sym
        raise "Invalid storage type: #{storage}" unless STORAGES_AVAILABLE.include?(storage)

        return storage
      end

      :local
    end
  end
end
