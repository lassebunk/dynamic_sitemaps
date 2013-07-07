host "www.example.com"

sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0

  # TODO: Add examples
end