host "www.example.com"

sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0

  # Ping search engines after sitemap generation
  # ping_with "http://#{host}/sitemap.xml"
  
  # TODO: Add examples
end