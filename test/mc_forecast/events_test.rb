
require "test_helper"
require "mc_forecast"

class EventsTest < Minitest::Test
  def test_recording_of_events
    e = McForecast::Simulation.new.run do |_state, _step, _trial|
      events = {}
      events[:coin] = rand > 0.5 ? 1 : 0

      [nil, events]
    end

    assert_in_delta(0.5, e[:coin][0], 0.05)
  end
end
