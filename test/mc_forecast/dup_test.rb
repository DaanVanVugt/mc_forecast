require "test_helper"
require "mc_forecast"

class DupTest < Minitest::Test
  def test_state_reset_to_initial_state
    McForecast::Simulation.new.run(init_state: { list: [] }) do |state, _step, _trial|
      state[:list] << 1
      assert_equal([1], state[:list])

      [state, {}]
    end
  end
end
