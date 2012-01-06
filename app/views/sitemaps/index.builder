xml.instruct!
xml.sitemapindex "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @pages.each_with_index do |page, i|
    xml.sitemap do
      xml.loc url_for(:host => request.host, :page => i + 1)
      if page.last_mod
        xml.lastmod page.last_mod.to_datetime.strftime("%Y-%m-%dT%H:%M:%S%:z")
      end
    end
  end
end
