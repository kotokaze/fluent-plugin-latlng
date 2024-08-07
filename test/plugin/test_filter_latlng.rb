require "helper"
require "fluent/plugin/filter_latlng.rb"

class LatlngFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::LatlngFilter).configure(conf)
  end
end
