module DynamicSitemaps
  class LocalStorage < Storage

    def move_to_destination
      generator.sitemaps.map(&:folder).uniq.each do |folder|
        destination = File.join(DynamicSitemaps.path, folder)
        FileUtils.mkdir_p destination
        FileUtils.rm_rf Dir.glob(File.join(destination, "*"))

        temp_files = File.join(DynamicSitemaps.temp_path, folder, "*.xml")
        FileUtils.mv Dir.glob(temp_files), destination
      end
    end

  end
end
