require 'test_helper'

class DynamicSitemapsTest < ActiveSupport::TestCase
  setup do
    DynamicSitemaps.reset!
  end

  test "defaults" do
    assert_equal Rails.root.join("public").to_s, DynamicSitemaps.path
    assert_equal "sitemaps", DynamicSitemaps.folder
    assert_equal "sitemap.xml", DynamicSitemaps.index_file_name
    assert !DynamicSitemaps.always_generate_index
    assert_equal Rails.root.join("config", "sitemap.rb").to_s, DynamicSitemaps.config_path
    assert_equal 50000, DynamicSitemaps.per_page
    assert_equal ["production"], DynamicSitemaps.ping_environments
  end

  test "configuration block" do
    DynamicSitemaps.configure do |config|
      config.folder = "mycustomfolder"
      config.per_page = 1234
    end

    assert_equal "mycustomfolder", DynamicSitemaps.folder
    assert_equal 1234, DynamicSitemaps.per_page
  end

  test "raises error on blank paths" do
    assert_nothing_raised do
      DynamicSitemaps.path = "/my/test/folder"
      DynamicSitemaps.folder = "my_sitemaps"
      DynamicSitemaps.config_path = "/my/config.rb"
    end

    assert_raises ArgumentError do
      DynamicSitemaps.path = ""
    end

    assert_raises ArgumentError do
      DynamicSitemaps.folder = ""
    end

    assert_raises ArgumentError do
      DynamicSitemaps.config_path = ""
    end
  end

  test "raises error when using old sitemap ping urls" do
    assert_raises RuntimeError do
      DynamicSitemaps.sitemap_ping_urls = ["http://test.com/sitemap.xml"]
    end
  end
end
