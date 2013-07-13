require 'test_helper'

class PingerTest < ActiveSupport::TestCase
  setup do
    DynamicSitemaps.reset!
  end

  test "pinging search engines" do
    stub_request :get, /^http:\/\/www\.google\.com\/webmasters\/sitemaps\/ping\?sitemap=.*/
    stub_request :get, /^http:\/\/www\.bing\.com\/webmaster\/ping\.aspx\?siteMap=.*/

    DynamicSitemaps.ping_environments << "test"
    DynamicSitemaps::Pinger.ping_search_engines_with ["http://test.dk/sitemap.xml", "http://other.com/test.xml"]

    ["http://www.google.com/webmasters/sitemaps/ping?sitemap=http%3A%2F%2Ftest.dk%2Fsitemap.xml",
     "http://www.bing.com/webmaster/ping.aspx?siteMap=http%3A%2F%2Ftest.dk%2Fsitemap.xml",
     "http://www.google.com/webmasters/sitemaps/ping?sitemap=http%3A%2F%2Fother.com%2Ftest.xml",
     "http://www.bing.com/webmaster/ping.aspx?siteMap=http%3A%2F%2Fother.com%2Ftest.xml"].each do |url|
      assert_requested :get, url
    end
  end

  test "doesnt ping when given no sitemap urls" do
    stub_request :get, //
    DynamicSitemaps.ping_environments << "test"
    DynamicSitemaps::Pinger.ping_search_engines_with []
    assert_not_requested :get, //
  end

  test "pings only for environments specified" do
    stub_request :get, //

    DynamicSitemaps::Pinger.ping_search_engines_with "http://test.com/sitemap.xml"
    assert_not_requested :get, //

    DynamicSitemaps.ping_environments << "test"
    DynamicSitemaps::Pinger.ping_search_engines_with "http://test.com/sitemap.xml"
    assert_requested :get, //, times: 2
  end

  test "custom search engine ping url" do
    stub_request :get, //
    DynamicSitemaps.ping_environments << "test"
    DynamicSitemaps.search_engine_ping_urls << "http://testsearch.com/ping?url=%s"
    DynamicSitemaps::Pinger.ping_search_engines_with "http://test.dk/sitemap.xml"

    [/www\.google\.com/,
     /www\.bing\.com/,
     "http://testsearch.com/ping?url=http%3A%2F%2Ftest.dk%2Fsitemap.xml"].each do |url|
      assert_requested :get, url
    end
  end

  test "handles failure when pinging" do
    stub_request(:get, //).to_raise(StandardError)
    DynamicSitemaps.ping_environments << "test"

    assert_nothing_raised do
      DynamicSitemaps::Pinger.ping_search_engines_with "http://test.dk/sitemap.xml"
    end
  end

  test "ping for environment" do
    assert DynamicSitemaps::Pinger.ping_for_environment?("production")
    assert !DynamicSitemaps::Pinger.ping_for_environment?("development")
    assert !DynamicSitemaps::Pinger.ping_for_environment?("test")
    assert !DynamicSitemaps::Pinger.ping_for_environment?("staging")
    
    DynamicSitemaps.ping_environments << "staging"
    assert DynamicSitemaps::Pinger.ping_for_environment?("staging")
    assert DynamicSitemaps::Pinger.ping_for_environment?("production")
  end
end