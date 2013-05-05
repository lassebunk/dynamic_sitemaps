xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @urls.each do |url|
    xml.url do
      xml.loc url.loc
      
      if url.last_mod
        xml.lastmod format_date(url.last_mod)
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
