module DynamicSitemaps
  class DatabaseStorage < Storage

    def move_to_destination
      Sitemap.delete_all
      generator.sitemaps.map(&:folder).uniq.each do |folder|
        temp_files = File.join(DynamicSitemaps.temp_path, folder, "*.xml")
        Dir.glob(temp_files).each do |temp_file|
          destination = File.join(folder, File.basename(temp_file))
          save_to_database(temp_file, destination)
        end
      end
    end

    protected
    def save_to_database(temp_file, destination)
      Sitemap.create! path: destination, content: File.read(temp_file)
    end

  end
end
