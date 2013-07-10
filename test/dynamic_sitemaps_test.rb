require 'test_helper'

class DynamicSitemapsTest < ActiveSupport::TestCase
  teardown do
    DynamicSitemaps.reset!
  end

  test "defaults" do
    assert_equal Rails.root.join("public").to_s, DynamicSitemaps.path
    assert_equal "sitemaps", DynamicSitemaps.folder
    assert_equal "sitemap.xml", DynamicSitemaps.index_file_name
    assert !DynamicSitemaps.always_generate_index
    assert_equal Rails.root.join("config", "sitemap.rb").to_s, DynamicSitemaps.config_path
    assert_equal 50000, DynamicSitemaps.per_page
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
end
