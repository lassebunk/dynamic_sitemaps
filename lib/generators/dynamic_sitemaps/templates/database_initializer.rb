require 'dynamic_sitemaps/storage/database_storage'

DynamicSitemaps.configure do |config|
  config.storage = DynamicSitemaps::DatabaseStorage
end
