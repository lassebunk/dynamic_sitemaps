xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @urls.each do |url|
    xml.url do
      xml.loc url.loc
      
      if url.last_mod
        xml.lastmod url.last_mod.to_datetime.strftime("%Y-%m-%dT%H:%M:%S%:z")
      end
      
      if url.change_freq
        xml.changefreq url.change_freq
      end
      
      if url.priority
        xml.priority url.priority
      end
    end
  end
end
