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

  test "index" do
    # TODO: Test index generation
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
      host "www.test.com"
      sitemap :test do
        url "http://www.test.com/test"
        url "http://www.test.com/test2"
      end
    end

    doc = open_sitemap
    
    assert_equal 2, doc.xpath("urlset/url").count
    assert_equal "http://www.test.com/test2", doc.xpath("urlset/url/loc").last.text
  end

  test "resourceful routes" do
    Product.create.tap do |product|
      product.update_column :updated_at, 213434.seconds.ago
    end
    Product.create slug: "test-slug"

    DynamicSitemaps.generate_sitemap do
      host "www.mytest.com"
      sitemap_for Product.scoped
    end

    doc = open_sitemap
    urls = doc.xpath("urlset/url")
    assert_equal 2, urls.count

    urls.first.tap do |url|
      assert_equal "http://www.mytest.com/products/1", url.xpath("loc").text
      assert_equal "2013-07-07T16:29:09+00:00", url.xpath("lastmod").text
      assert_nil url.at_xpath("priority")
      assert_nil url.at_xpath("changefreq")
    end

    urls.last.tap do |url|
      assert_equal "http://www.mytest.com/products/test-slug", url.xpath("loc").text
      assert_equal "2013-07-10T03:46:23+00:00", url.xpath("lastmod").text
      assert_nil url.at_xpath("priority")
      assert_nil url.at_xpath("changefreq")
    end
  end

  test "resourceful routes with custom urls" do
    Product.create featured: true
    Product.create featured: false

    DynamicSitemaps.generate_sitemap do
      host "www.mytest.com"
      sitemap_for Product.scoped do |product|
        url product, last_mod: 1234.seconds.ago, priority: (product.featured? ? 1.0 : nil), change_freq: "weekly"
        url product_comments_url(product)
      end
    end

    doc = open_sitemap
    urls = doc.xpath("urlset/url")
    assert_equal 4, urls.count

    urls[0].tap do |url|
      assert_equal "http://www.mytest.com/products/1", url.xpath("loc").text
      assert_equal "2013-07-10T03:25:49+00:00", url.xpath("lastmod").text
      assert_equal "weekly", url.xpath("changefreq").text
      assert_equal "1.0", url.xpath("priority").text
    end

    urls[1].tap do |url|
      assert_equal "http://www.mytest.com/products/1/comments", url.xpath("loc").text
      assert_nil url.at_xpath("lastmod")
      assert_nil url.at_xpath("changefreq")
      assert_nil url.at_xpath("priority")
    end

    urls[2].tap do |url|
      assert_equal "http://www.mytest.com/products/2", url.xpath("loc").text
      assert_nil url.at_xpath("priority")
    end
  end

  test "sitemap_for complains if not given a relation" do
    assert_raises ArgumentError do
      DynamicSitemaps.generate_sitemap do
        host "www.mytest.com"
        sitemap_for Product.all
      end
    end
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