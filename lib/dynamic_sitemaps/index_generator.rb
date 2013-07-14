module DynamicSitemaps
  class IndexGenerator
    attr_reader :sitemaps # Array of sitemap results

    # Initialize the class with an array of SitemapResult
    def initialize(sitemaps)
      @sitemaps = sitemaps
    end

    def generate
      sitemaps.group_by(&:folder).each do |folder, sitemaps|
        index_path = "#{DynamicSitemaps.temp_path}/#{folder}/#{DynamicSitemaps.index_file_name}"

        if !DynamicSitemaps.always_generate_index && sitemaps.count == 1 && sitemaps.first.files.count == 1
          file_path = "#{DynamicSitemaps.temp_path}/#{folder}/#{sitemaps.first.files.first}"
          FileUtils.copy file_path, index_path
          File.delete file_path
        else
          File.open(index_path, "w") do |file|
            write_beginning(file)
            write_sitemaps(file, sitemaps)
            write_end(file)
          end
        end
      end
    end

    def write_beginning(file)
      file.puts '<?xml version="1.0" encoding="UTF-8"?>',
                '<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
    end

    def write_sitemaps(file, sitemaps)
      sitemaps.each do |sitemap|
        sitemap.files.each do |file_name|
          file.puts '<sitemap>',
                    "<loc>http://#{sitemap.host}/#{sitemap.folder}/#{file_name}</loc>",
                    '</sitemap>'
        end
      end
    end

    def write_end(file)
      file.puts '</sitemapindex>'
    end
  end
end