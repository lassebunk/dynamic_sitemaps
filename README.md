# DynamicSitemaps

Dynamic Sitemaps is a plugin for Ruby on Rails that enables you to easily create flexible, dynamic sitemaps. It creates sitemaps in the [sitemaps.org](http://sitemaps.org) standard which is supported by several crawlers including Google, Bing, and Yahoo.

Dynamic Sitemaps is designed to be very (very) simple so there's a lot you cannot do, but possibly don't need (I didn't). If you need an advanced sitemap generator, please see Karl Varga's [SitemapGenerator](https://github.com/kjvarga/sitemap_generator).

## Version 2.0

Version 2.0 makes it possible to make very large sitemaps (up to 2.5 billion URLs) in a fast and memory efficient way; it will be built for large amounts of data, i.e. millions of URLs without pushing your server to the limit, memory and CPU wise.

Version 2.0 is not compatible with version 1.0 (although the configuration DSL looks somewhat the same) as version 2.0 generates static sitemap XML files whereas 1.0 generated them dynamically on each request (slow for large sitemaps).

## Installation

Add this line to your application's Gemfile:

    gem "dynamic_sitemaps", "2.0.0.beta"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamic_sitemaps

To generate a simple example config file in `config/sitemap.rb`:

    $ rails generate dynamic_sitemaps:install

## Basic usage

The configuration file in `config/sitemap.rb` goes like this (also see the production example below for more advance usage like multiple sites / hosts, etc.):

```ruby
host "www.example.com"

# Basic sitemap – you can change the name :site as you wish
sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
end
```

The host is needed to generate the URLs because the rake task doesn't know anything about the host being used.

Then, to generate the sitemap:

    $ rake sitemap:generate

This will, by default, empty `<project root>/public/sitemaps/*` and generate a `sitemap.xml` that will look like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://www.example.com/</loc>
    <lastmod>2013-07-08T17:02:45+02:00</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

You then need to symlink from `public/sitemap.xml` (or whatever you choose) to `public/sitemaps/sitemap.xml`:

    $ ln -s /path/to/project/public/sitemaps/sitemap.xml /path/to/project/public/sitemap.xml

See the below production example for inspiration on how to do this with [Capistrano](https://github.com/capistrano/capistrano), and other things like multiple sites / hosts, etc.

If a sitemap contains over 50,000 URLs, then by default, as specified by the [sitemaps.org](http://sitemaps.org) standard, DynamicSitemaps will split it into multiple sitemaps and generate an index file that will also be named `public/sitemaps/sitemap.xml` by default.
The sitemap files will then be named `site.xml`, `site2.xml`, `site3.xml`, and so on, and the index file will link to these files using the host set with `host`.

## Automatically mapping resources

```ruby
host "www.example.com"

# Basic sitemap
sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
end

# Automatically link to all pages using the routes specified
# using "resources :pages" in config/routes.rb. This will also
# automatically set <lastmod> to the date and time in page.updated_at.
sitemap_for Page.scoped

# For products with special sitemap name and priority, and link to comments
sitemap_for Product.published, name: :published_products do |product|
  url product, last_mod: product.updated_at, priority: (product.featured? ? 1.0 : 0.7)
  url product_comments_url(product)
end
```

This generates the sitemap files `site.xml`, `pages.xml`, and `products.xml` and links them together in the `sitemap.xml` index file, splitting them into multiple sitemap files if the number of URLs exceeds 50,000.

The argument passed to `sitemap_for` needs to respond to [`#find_each`](http://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each), like an ActiveRecord [Relation](http://api.rubyonrails.org/classes/ActiveRecord/Relation.html).
This is to ensure that the records from the database are lazy loaded 1,000 at a time, so that it doesn't accidentally load millions of records in one call when the configuration file is read.
Therefore we use `Page.scoped` instead of the normal `Page.all`.

## Custom configuration

You can configure different options of how DynamicSitemaps behaves, including xx.

In an initializer, e.g. `config/initializers/dynamic_sitemaps.rb`:

```ruby
# These are the built-in defaults, so you don't need to specify them.
DynamicSitemaps.configure do |config|
  config.path = Rails.root.join("public")
  config.folder = "sitemaps" # This folder is emptied on each sitemap generation
  config.index_file_name = "sitemap.xml"
  config.always_generate_index = false # Makes sitemap.xml contain the sitemap
                                       # (e.g. site.xml) when only one sitemap
                                       #  file has been generated
  config.config_path = Rails.root.join("config", "sitemap.rb")
end
```

## Pinging search engines

DynamicSitemaps can automatically ping Google and Bing (and other search engines you specify) with the sitemap when the generation finishes.

In e.g. `config/initializers/dynamic_sitemaps.rb`:

```ruby
DynamicSitemaps.configure do |config|
  # Default is Google and Bing
  config.search_engine_ping_urls << "http://customsearchengine.com/ping?url=%s"
  
  # Which URLs to tell the search engines about
  config.sitemap_ping_urls = ["http://www.domain.com/sitemap.xml"]

  # Or dynamically, to ensure that the sites are loaded on each call
  # and not just when the initializer is first run
  config.sitemap_ping_urls = -> { Site.all.map { |site| "http://#{site.domain}/sitemap.xml" } }
end
```

## Production example

TODO

## Contributing

Help is always appreciated whether it be improvement of the code, testing, or adding new relevant features.
Please create an [issue](https://github.com/lassebunk/dynamic_sitemaps/issues) before implementing a new feature, so we can discuss it in advance. Thanks.

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request