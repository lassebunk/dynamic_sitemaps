require 'test_helper'

class PingerTest < ActiveSupport::TestCase
  setup do
    DynamicSitemaps.reset!
  end

  test "ping for environment" do
    assert DynamicSitemaps::Pinger.ping_for_environment?("production")
    assert !DynamicSitemaps::Pinger.ping_for_environment?("development")
    assert !DynamicSitemaps::Pinger.ping_for_environment?("test")
    assert !DynamicSitemaps::Pinger.ping_for_environment?("staging")
    
    DynamicSitemaps.ping_environments << "staging"
    assert DynamicSitemaps::Pinger.ping_for_environment?("staging")
  end
end