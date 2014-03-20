host "www.mytest.com"
protocol "https"

sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
end