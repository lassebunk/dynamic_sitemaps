require "test_helper"
require "nokogiri"
require "timecop"

class GeneratorTest < ActiveSupport::TestCase
  setup do
    Timecop.freeze Time.new(2013, 10, 7, 13, 46, 23, "+10:00")
    path = File.dirname(__FILE__) + "/sitemaps"
    FileUtils.rm_rf path
    DynamicSitemaps.path = path
  end

  teardown do
    DynamicSitemaps.reset!
  end

  test "defaults" do
    DynamicSitemaps.reset!
    assert_equal Rails.root.join("public").to_s, DynamicSitemaps.path
    assert_equal "sitemaps", DynamicSitemaps.folder
    assert_equal "sitemap.xml", DynamicSitemaps.index_file_name
    assert !DynamicSitemaps.always_generate_index
    assert_equal Rails.root.join("config", "sitemap.rb").to_s, DynamicSitemaps.config_path
    assert_equal 50000, DynamicSitemaps.per_page
  end

  test "generate basic sitemap with default settings" do
    FileUtils.rm_rf Rails.root.join("public", "sitemaps")
    DynamicSitemaps.reset! # Reset because test setup sets custom test settings. We want to test the default Rails settings.
    DynamicSitemaps.generate_sitemap

    doc = Nokogiri::XML(open(Rails.root.join("public", "sitemaps", "sitemap.xml")).read)
    assert_equal ({ "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" }), doc.namespaces
    doc.remove_namespaces!

    url = doc.xpath("urlset/url")
    assert_equal 1, url.count
    assert_equal "http://www.mytest.com/", url.xpath("loc").text
    assert_equal "2013-10-07T05:46:23+02:00", url.xpath("lastmod").text
    assert_equal "daily", url.xpath("changefreq").text
    assert_equal "1.0", url.xpath("priority").text
  end
end