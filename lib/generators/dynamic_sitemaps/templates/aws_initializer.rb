require 'dynamic_sitemaps/storage/s3_storage'

DynamicSitemaps.configure do |config|
  config.storage               = DynamicSitemaps::S3Storage
  config.bucket_name           = 'bucket_name'
  config.aws_access_key_id     = 'aws_access_key_id'
  config.aws_secret_access_key = 'aws_secret_access_key'
end
