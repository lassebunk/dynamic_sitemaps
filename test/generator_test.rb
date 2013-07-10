require "test_helper"
require "nokogiri"
require "timecop"

class GeneratorTest < ActiveSupport::TestCase
  setup do
    Timecop.freeze Time.new(2013, 7, 10, 13, 46, 23, "+10:00")
    FileUtils.rm_rf Rails.root.join("public", "sitemaps")
    DynamicSitemaps.reset!
  end

  test "basic sitemap with default settings" do
    DynamicSitemaps.generate_sitemap

    doc = open_sitemap(remove_namespaces: false)
    assert_equal ({ "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" }), doc.namespaces
    doc.remove_namespaces!

    url = doc.xpath("urlset/url")
    assert_equal 1, url.count
    assert_equal "http://www.mytest.com/", url.xpath("loc").text
    assert_equal "2013-07-10T03:46:23+00:00", url.xpath("lastmod").text
    assert_equal "daily", url.xpath("changefreq").text
    assert_equal "1.0", url.xpath("priority").text

    # Test that it only keeps sitemap.xml when there's no need for an index
    assert !File.exists?(Rails.root.join("public", "sitemaps", "site.xml"))
  end

  test "always generate index" do
    DynamicSitemaps.always_generate_index = true
    DynamicSitemaps.generate_sitemap

    doc = open_sitemap
    assert_equal "http://www.mytest.com/sitemaps/site.xml", doc.xpath("sitemapindex/sitemap/loc").text

    doc = open_sitemap(Rails.root.join("public", "sitemaps", "site.xml"))
    assert_equal "http://www.mytest.com/", doc.xpath("urlset/url/loc").text
  end

  test "sitemap based on block" do
    DynamicSitemaps.generate_sitemap do
      sitemap :test do
        url "http://www.test.com/test"
        url "http://www.test.com/test2"
      end
    end

    doc = open_sitemap
    
    assert_equal 2, doc.xpath("urlset/url").count
    assert_equal "http://www.test.com/test2", doc.xpath("urlset/url/loc").last.text
  end

private

  # Opens a sitemap file using Nokogiri::XML and removes namespaces by default.
  # 
  #   open_sitemap # => Nokogiri::XML with the contents of <rails root>/public/sitemaps/sitemap.xml
  #   open_sitemap "/path/to/sitemap.xml"
  #   open_sitemap "/path/to/sitemap.xml", remove_namespaces: false
  def open_sitemap(*args)
    options = args.extract_options!
    doc = Nokogiri::XML(open(args[0] || Rails.root.join("public", "sitemaps", "sitemap.xml")))
    doc.remove_namespaces! unless options[:remove_namespaces] == false
    doc
  end

end