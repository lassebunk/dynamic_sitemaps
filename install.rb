require 'fileutils'

cp  File.join(File.dirname(__FILE__), "initializers", "sitemap.rb"),
    File.join(Rails.root, "config", "initializers")