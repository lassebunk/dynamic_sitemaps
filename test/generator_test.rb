require "test_helper"
require "nokogiri"
require "timecop"

class GeneratorTest < ActiveSupport::TestCase
  setup do
    Timecop.freeze Time.new(2013, 10, 7, 13, 46, 23, "+10:00")
    FileUtils.rm_rf Rails.root.join("public", "sitemaps")
    DynamicSitemaps.reset!
  end

  test "generation of basic sitemap with default settings" do
    DynamicSitemaps.generate_sitemap

    doc = Nokogiri::XML(open(Rails.root.join("public", "sitemaps", "sitemap.xml")))
    assert_equal ({ "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" }), doc.namespaces
    doc.remove_namespaces!

    url = doc.xpath("urlset/url")
    assert_equal 1, url.count
    assert_equal "http://www.mytest.com/", url.xpath("loc").text
    assert_equal "2013-10-07T03:46:23+00:00", url.xpath("lastmod").text
    assert_equal "daily", url.xpath("changefreq").text
    assert_equal "1.0", url.xpath("priority").text

    # TODO: Assert that index does not exist
  end

  test "generation of sitemap based on block" do
    DynamicSitemaps.generate_sitemap do
      sitemap :test do
        url "http://www.test.com/test"
        url "http://www.test.com/test2"
      end
    end

    doc = Nokogiri::XML(open(Rails.root.join("public", "sitemaps", "sitemap.xml")))
    doc.remove_namespaces!
    
    assert_equal 2, doc.xpath("urlset/url").count
    assert_equal "http://www.test.com/test2", doc.xpath("urlset/url/loc").last.text
  end
end