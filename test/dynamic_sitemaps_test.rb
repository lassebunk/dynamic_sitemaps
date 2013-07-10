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
  end
end
