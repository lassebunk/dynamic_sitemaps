# DynamicSitemaps

Dynamic Sitemaps is a plugin for Ruby on Rails that enables you to easily create flexible, dynamic sitemaps. It creates sitemaps in the [sitemaps.org](http://sitemaps.org) standard which is supported by several crawlers including Google, Bing, and Yahoo.

Dynamic Sitemaps is designed to be very (very) simple so there's a lot you cannot do, but possibly don't need (I didn't). If you need an advanced sitemap generator, please see Karl Varga's [SitemapGenerator](https://github.com/kjvarga/sitemap_generator).

## Planned for version 2.0 (this branch)

Version 2.0 will make it possible to make very large sitemaps (up to 2.5 billion URLs) in a fast and memory efficient way; it will be built for large amounts of data, i.e. millions of URLs without pushing your server to the limit, memory and CPU wise.

Version 2.0 will not be compatible with version 1.0 as version 2.0 will generate static sitemap XML files whereas 1.0 generates them dynamically on each request.

Idea for the version 2.0 DSL, in ```config/sitemap.rb```:

```ruby
host "www.mysite.com"

sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
  url contact_url
  Page.all.each do |page|
    url page, last_mod: page.updated_at
  end
end

# All products and editions URLs
sitemap :products, Product do |product|
  url product, last_mod: product.updated_at
  url product_editions_url(product)
end

# Autogenerate a tags sitemap with URLs for all tags containing products.
# Automatically sets last_mod to tag.updated_at.
sitemap Tag.where("products_count > 0")
```

You then run:

```bash
$ rake sitemap:generate
```

This will generate the sitemaps, remove all files from ```public/sitemaps``` replacing them with:

```bash
- public/sitemaps/index.xml
- public/sitemaps/site.xml
- public/sitemaps/products.xml
- public/sitemaps/products2.xml
- public/sitemaps/products3.xml # etc.
- public/sitemaps/tags.xml
- public/sitemaps/tags2.xml # etc.
```

And symlink ```/sitemap.xml``` to ```/sitemaps/sitemap.xml``` because the sitemaps.org spec only allows URLs in a sitemap to be *below* the ```sitemap.xml``` index file:

```bash
$ ln -s /var/www/mysite/public/sitemaps/index.xml /var/www/mysite/public/sitemap.xml
```

If you use Capistrano and have a ```shared``` folder:

```bash
$ mkdir -p /var/www/mysite/shared/sitemaps
$ rm -r /var/www/mysite/current/public/sitemaps # if uploaded accidentally
$ ln -s /var/www/mysite/shared/sitemaps /var/www/mysite/current/public/sitemaps
```

If for example you have multiple subdomains, then in ```config/sitemap.rb```:

```ruby
Site.all.each do |site|
  host "#{site.subdomain}.mysite.com"
  path Rails.root.join("public", "sitemaps", site.subdomain)

  url root_url
  sitemap site.products
  # etc.
end
```

## Installation

Add this line to your application's Gemfile:

    gem "dynamic_sitemaps", git: "git://github.com/lassebunk/dynamic_sitemaps.git", branch: "2.0"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamic_sitemaps

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
