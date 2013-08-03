[![Build Status](https://secure.travis-ci.org/lassebunk/dynamic_sitemaps.png)](http://travis-ci.org/lassebunk/dynamic_sitemaps)

# DynamicSitemaps

Dynamic Sitemaps is a plugin for [Ruby on Rails](http://rubyonrails.org) that enables you to easily create flexible, dynamic sitemaps. It creates sitemaps in the [sitemaps.org](http://sitemaps.org) standard which is supported by several crawlers including Google, Bing, and Yahoo.

Dynamic Sitemaps is designed to be very (very) simple so there's a lot you cannot do, but possibly don't need (I didn't). If you need an advanced sitemap generator, please see Karl Varga's [SitemapGenerator](https://github.com/kjvarga/sitemap_generator).

## Version 2.0

Version 2.0 makes it possible to make very large sitemaps (up to 2.5 billion URLs) in a fast and memory efficient way; it is built for large amounts of data, i.e. millions of URLs without pushing your server to the limit, memory and CPU wise.

Version 2.0 is not compatible with version 1.0 (although the configuration DSL looks somewhat the same) as version 2.0 generates static sitemap XML files whereas 1.0 generated them dynamically on each request (slow for large sitemaps).

## Requirements

DynamicSitemaps is tested in Rails 3.2.13 (and works in Rails 4.0.0, too) using Ruby 1.9.3 and 2.0.0, but should work in other versions of Rails 3 and above and Ruby 1.9 and above. Please create an [issue](https://github.com/lassebunk/dynamic_sitemaps/issues) if you encounter any problems.

## Installation

Add this line to your application's Gemfile:

    gem "dynamic_sitemaps"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynamic_sitemaps

To generate a simple example config file in `config/sitemap.rb`:

    $ rails generate dynamic_sitemaps:install

If you want to use version 1.0 (v1.0.8) of DynamicSitemaps, please see [v1.0.8](https://github.com/lassebunk/dynamic_sitemaps/tree/da0f78ddb1e6a471d6d5715d492295da99f5e682) of the project. Please note that this version isn't good for large sitemaps as it generates them dynamically on each request.

## Basic usage

The configuration file in `config/sitemap.rb` goes like this (also see the production example below for more advance usage like multiple sites / hosts, etc.):

```ruby
host "www.example.com"

# Basic sitemap – you can change the name :site as you wish
sitemap :site do
  url root_url, last_mod: Time.now, change_freq: "daily", priority: 1.0
end

# Pings search engines after generation has finished
ping_with "http://#{host}/sitemap.xml"
```

The host is needed to generate the URLs because the rake task doesn't know anything about the host being used.

Then, to generate the sitemap:

    $ rake sitemap:generate

This will, by default, generate a `sitemap.xml` file in `<project root>/public/sitemaps` that will look like this:

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

## Automatic sitemaps for resourceful routes

DynamicSitemaps can automatically generate sitemaps for ActiveRecord models with the built-in Rails [resourceful routes](http://guides.rubyonrails.org/routing.html#resource-routing-the-rails-default) (the ones you create using `routes :model_name`).

Example:

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

This generates the sitemap files `site.xml`, `pages.xml`, and `published_products.xml` and links them together in the `sitemap.xml` index file, splitting them into multiple sitemap files if the number of URLs exceeds 50,000.

The argument passed to `sitemap_for` needs to respond to [`#find_each`](http://api.rubyonrails.org/classes/ActiveRecord/Batches.html#method-i-find_each), like an ActiveRecord [Relation](http://api.rubyonrails.org/classes/ActiveRecord/Relation.html).
This is to ensure that the records from the database are lazy loaded 1,000 at a time, so that it doesn't accidentally load millions of records in one call when the configuration file is read.
Therefore we use `Page.scoped` instead of the normal `Page.all`.

## Custom configuration

You can configure different options of how DynamicSitemaps behaves, including the sitemap path and index file name.

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
  config.per_page = 50000
end
```

## Pinging search engines

DynamicSitemaps can automatically ping Google and Bing (and other search engines you specify) with the sitemap when the generation finishes.

In `config/sitemap.rb`:

```ruby
host "www.example.com"

sitemap :site do
  url root_url
end

ping_with "http://#{host}/sitemap.xml"
```

To customize it, in e.g. `config/initializers/dynamic_sitemaps.rb`:

```ruby
DynamicSitemaps.configure do |config|
  # Default is Google and Bing
  config.search_engine_ping_urls << "http://customsearchengine.com/ping?url=%s"

  # Default is pinging only in production
  config.ping_environments << "staging"
end
```

## In case of failure

DynamicSitemaps generates to a temporary directory (`<rails root>/tmp/dynamic_sitemaps`) first and, when finished, moves the files into the destination (by default `public/sitemaps`).
So in case you have generated a sitemap succesfully and the next sitemap generation fails, your sitemap files will remain untouched and available.

## Production example with multiple domains, Capistrano, and Whenever

This is an example of a real production app that uses DynamicSitemaps with multiple sites and domains in one app, [Capistrano](https://github.com/capistrano/capistrano) for deployment, and [Whenever](https://github.com/javan/whenever) for crontab scheduling.

### Sitemap setup

In `config/sitemap.rb`:

```ruby
Site.all.each do |site|
  folder "sitemaps/#{site.key}"
  host site.domain

  sitemap :site do
    url root_url, priority: 1.0, change_freq: "daily"
    url blog_posts_url
    url tags_url
  end

  sitemap_for site.pages.where("slug != 'home'")
  sitemap_for site.blog_posts.published
  sitemap_for site.tags.scoped

  sitemap_for site.products.where("type_id != ?", ProductType.find_by_key("unknown").id) do |product|
    url product, last_mod: product.updated_at, priority: (product.featured? ? 1.0 : 0.7)
  end

  ping_with "http://#{host}/sitemap.xml"
end
```

### Routing the default sitemap

#### Route for sitemap.xml and robots.txt

In `config/routes.rb`:

```ruby
get "sitemap.xml" => "home#sitemap", format: :xml, as: :sitemap
get "robots.txt" => "home#robots", format: :text, as: :robots
```

#### Controller

In `app/controllers/home_controller.rb`:

```ruby
class HomeController < ApplicationController
  # ...

  def sitemap
    path = Rails.root.join("public", "sitemaps", current_site.key, "sitemap.xml")
    if File.exists?(path)
      render xml: open(path).read
    else
      render text: "Sitemap not found.", status: :not_found
    end
  end
  
  def robots
  end
end
```

#### View for robots.txt

In `app/views/home/robots.text.erb`:

```html
Sitemap: <%= sitemap_url %>
```

### Deployment with Capistrano

[Capistrano](https://github.com/capistrano/capistrano) deployment configuration in `config/deploy.rb`:

```ruby
after "deploy:update_code", "sitemaps:create_symlink"

namespace :sitemaps do
  task :create_symlink, roles: :app do
    run "mkdir -p #{shared_path}/sitemaps"
    run "rm -rf #{release_path}/public/sitemaps"
    run "ln -s #{shared_path}/sitemaps #{release_path}/public/sitemaps"
  end
end
```

For automatic crontab scheduling with [Whenever](https://github.com/javan/whenever), in `config/schedule.rb`:

```ruby
every 1.day, at: "6am" do
  rake "sitemap:generate"
end
```

This will automatically generate the sitemaps and ping Google and Bing every day at 6am using the sitemap URLs configured above.

## Problems?

If you encounter any problems with DynamicSitemaps, please create an [issue](https://github.com/lassebunk/dynamic_sitemaps/issues).
If you want to fix the problem (please do :smile:), please see below.

## Contributing

Help is always appreciated whether it be improvement of the code, testing, or adding new relevant features.
Please create an [issue](https://github.com/lassebunk/dynamic_sitemaps/issues) before implementing a new feature, so we can discuss it in advance. Thanks.

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
