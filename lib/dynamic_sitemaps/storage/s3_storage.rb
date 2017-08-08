require 'aws-sdk'

module DynamicSitemaps
  class S3Storage < Storage

    def move_to_destination
      generator.sitemaps.map(&:folder).uniq.each do |folder|
        temp_files = File.join(DynamicSitemaps.temp_path, folder, "*.xml")
        Dir.glob(temp_files).each do |temp_file|
          destination = File.join(folder, File.basename(temp_file))
          move_to_s3(temp_file, destination)
        end
      end
    end

    protected
    def move_to_s3(temp_file, destination)
      puts "Moved #{temp_file} > #{destination}"
      # s3.buckets[DynamicSitemaps.bucket_name].objects[destination].write(data: File.open(temp_file), acl: :public_read)
    end

    def s3
      @s3 ||= AWS::S3.new(access_key_id: DynamicSitemaps.aws_access_key, secret_access_key: DynamicSitemaps.aws_secret_access_key)
    end

  end
end
