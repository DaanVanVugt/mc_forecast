require "test_helper"
require "mc_forecast"

class EventsTest < Minitest::Test
  def test_recording_of_events
    e = McForecast::Simulation.new.run do |_state, _step, _trial|
      events = {}
      events[:coin] = rand > 0.5 ? 1 : 0

      [nil, events]
    end

    assert_in_delta(0.5, e[:coin][:mean][0], 0.05)
    assert_equal(0, e[:coin][:quantiles][0.025][0])
    assert_equal(1, e[:coin][:quantiles][0.975][0])
  end

  def test_quantiles
    e = McForecast::Simulation.new.run do |_state, _step, _trial|
      events = {}
      events[:rand] = rand

      [nil, events]
    end

    assert_in_delta(0.5, e[:rand][:mean][0], 0.05)
    assert_in_delta(0.025, e[:rand][:quantiles][0.025][0], 0.03)
    assert_in_delta(0.975, e[:rand][:quantiles][0.975][0], 0.03)
  end
end
