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

  def test_sums_one
    n_steps = ((rand * 30) + 10).to_i
    e = McForecast::Simulation.new.run(steps: n_steps) do |_state, _step, _trial|
      events = {}
      events[:one] = 1

      [nil, events]
    end

    assert_in_delta(n_steps, e[:one][:sum][:mean], 0.03)
    assert_in_delta(n_steps, e[:one][:sum][:quantiles][0.025], 0.03)
    assert_in_delta(n_steps, e[:one][:sum][:quantiles][0.975], 0.03)
  end

  def test_sums_rand
    n_steps = 12
    e = McForecast::Simulation.new.run(steps: n_steps) do |_state, _step, _trial|
      events = {}
      events[:rand] = rand

      [nil, events]
    end

    # we do 1000 trials
    assert_in_delta(6, e[:rand][:sum][:mean], 0.1)
    # this gets a bit hairy:
    # see https://stats.stackåexchange.com/questions/41467/consider-the-sum-of-n-uniform-distributions-on-0-1-or-z-n-why-does-the
    # given enough samples we'll just assume it's like a gaussian
    # see https://www.johndcook.com/blog/2009/02/12/sums-of-uniform-random-values/ to get to these numbers
    # and the steps were chosen to make it one centered at 6, with variance 1 (and thus sigma 1)
    # use https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule
    # the below does not work to a very high accuracy, and we may have to do some math to get more accurate values
    assert_in_delta(4, e[:rand][:sum][:quantiles][0.025], 0.3)
    assert_in_delta(8, e[:rand][:sum][:quantiles][0.975], 0.3)
  end

  def test_ranges_analysis_with_specific_ranges # rubocop:disable Minitest/MultipleAssertions
    n_steps = 22 # Adjusted to ensure the range up to 21 is included
    ranges = [0..9, 10..21] # Define the specified ranges to analyze

    e = McForecast::Simulation.new.run(steps: n_steps, ranges: ranges) do |_state, step, _trial|
      events = {}
      # Use a simple linear function for the event values: event value = step
      events[:linear] = step

      [nil, events]
    end

    # Test the mean calculations for each range
    # For the first range (0..9), the mean should be the midpoint, i.e., 4.5
    assert_in_delta(4.5, e[:linear][:ranges][0..9][:mean][0], 0.05, "Mean calculation for the first range is incorrect")
    # For the second range (10..21), the mean should be the midpoint, i.e., 15.5
    assert_in_delta(
      15.5,
      e[:linear][:ranges][10..21][:mean][0],
      0.05,
      "Mean calculation for the second range is incorrect"
    )

    # Test the quantile calculations for each range
    # For a linear sequence, the quantiles at 0.025 and 0.975 should closely match the start and end of the range, respectively.
    # For the first range (0..9)
    assert_in_delta(
      0,
      e[:linear][:ranges][0..9][:quantiles][0.025][0],
      0.05,
      "Quantile calculation at 0.025 for the first range is incorrect"
    )
    assert_in_delta(
      9,
      e[:linear][:ranges][0..9][:quantiles][0.975][0],
      0.05,
      "Quantile calculation at 0.975 for the first range is incorrect"
    )

    # For the second range (10..21)
    assert_in_delta(
      10,
      e[:linear][:ranges][10..21][:quantiles][0.025][0],
      0.05,
      "Quantile calculation at 0.025 for the second range is incorrect"
    )
    assert_in_delta(
      21,
      e[:linear][:ranges][10..21][:quantiles][0.975][0],
      0.05,
      "Quantile calculation at 0.975 for the second range is incorrect"
    )
  end
end
