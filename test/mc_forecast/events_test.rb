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
end
