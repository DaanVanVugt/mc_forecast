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
    # see https://stats.stackexchange.com/questions/41467/consider-the-sum-of-n-uniform-distributions-on-0-1-or-z-n-why-does-the
    # given enough samples we'll just assume it's like a gaussian
    # see https://www.johndcook.com/blog/2009/02/12/sums-of-uniform-random-values/ to get to these numbers
    # and the steps were chosen to make it one centered at 6, with variance 1 (and thus sigma 1)
    # use https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule
    # the below does not work to a very high accuracy, and we may have to do some math to get more accurate values
    assert_in_delta(4, e[:rand][:sum][:quantiles][0.025], 0.3)
    assert_in_delta(8, e[:rand][:sum][:quantiles][0.975], 0.3)
  end

  def test_ranges_zero
    n_steps = 22
    ranges = [0..9, 10..21]
    e = McForecast::Simulation.new.run(steps: n_steps, ranges: ranges) do |_state, _step, _trial|
      events = {}
      events[:zero] = 0

      [nil, events]
    end
    assert_in_delta(0, e[:zero][:ranges][ranges[0]][:mean], 0.03)
    assert_in_delta(0, e[:zero][:ranges][ranges[1]][:mean], 0.03)
  end

  def test_ranges_one # rubocop:disable Minitest/MultipleAssertions
    n_steps = 22
    ranges = [0..9, 10..21]
    e = McForecast::Simulation.new.run(steps: n_steps, ranges: ranges) do |_state, _step, _trial|
      events = {}
      events[:one] = 1

      [nil, events]
    end

    assert_in_delta(ranges[0].size, e[:one][:ranges][ranges[0]][:mean], 0.03)
    assert_in_delta(ranges[0].size, e[:one][:ranges][ranges[0]][:quantiles][0.025], 0.03)
    assert_in_delta(ranges[0].size, e[:one][:ranges][ranges[0]][:quantiles][0.975], 0.03)
    assert_in_delta(ranges[1].size, e[:one][:ranges][ranges[1]][:mean], 0.03)
    assert_in_delta(ranges[1].size, e[:one][:ranges][ranges[1]][:quantiles][0.025], 0.03)
    assert_in_delta(ranges[1].size, e[:one][:ranges][ranges[1]][:quantiles][0.975], 0.03)
  end

  def test_ranges_rand # rubocop:disable Minitest/MultipleAssertions
    n_steps = 22
    ranges = [0..9, 10..21]
    e = McForecast::Simulation.new.run(steps: n_steps, ranges: ranges) do |_state, _step, _trial|
      events = {}
      events[:rand] = rand

      [nil, events]
    end

    # The function 'rand' is a continuous uniform random variable on the interval [0,1]
    # Its variance can be described as (b-a)^2 / 12 = (1-0)^2 / 12 = 1/12
    # As noted earlier, the sum of n random variables will approximately follow a normal
    # distribution with mean n/2 and variance n/12 when n is large (Central Limit Theorem).
    # The standard deviation is sqrt(n/12). Same as before, we can use the 68-95-99.7 rule
    # to get the quantiles.
    # For range 0..9, the mean is 10/2 = 5 and the standard deviation is sqrt(10/12) = 0.9129
    assert_in_delta(5, e[:rand][:ranges][ranges[0]][:mean], 0.1)
    assert_in_delta(3.1742, e[:rand][:ranges][ranges[0]][:quantiles][0.025], 0.3)
    assert_in_delta(6.8257, e[:rand][:ranges][ranges[0]][:quantiles][0.975], 0.3)
    # For range 10..21, the mean is 12/2 = 6 and the standard deviation is sqrt(12/12) = 1
    assert_in_delta(6, e[:rand][:ranges][ranges[1]][:mean], 0.1)
    assert_in_delta(4, e[:rand][:ranges][ranges[1]][:quantiles][0.025], 0.3)
    assert_in_delta(8, e[:rand][:ranges][ranges[1]][:quantiles][0.975], 0.3)
  end
end
