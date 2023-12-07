require "test_helper"

class McForecastTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::McForecast::VERSION
  end
end
