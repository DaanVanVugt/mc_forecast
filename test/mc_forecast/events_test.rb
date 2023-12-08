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
  end

  def test_employee_development
    @odds = {
      # SOURCE: https://digitaal.scp.nl/arbeidsmarkt-in-kaart-werkgevers-editie-4/hoe-ontwikkelen-in-uit-en-doorstroom-van-personeel-zich/
      # noteer eenheden (naar maand)
      instroom: 0.162, # 16.2% per year
      uitstroom: 0.12
    }

    init = {
      employees => [
        {
          tenure: 0 # months
        }
      ]
    }
    e = McForecast::Simulation.new.run(init_state: init, steps: 12) do |state, _step, _trial|
      events = {}

      t_start_employees = state.employees.length

      # In dienst treding (instroom)
      instroom = (t_start_employees * @odds[instroom]).round
      instroom.times do
        state.employees << Employee.new
      end
      events[:instroom] = instroom

      # EOL
      # Breakdowns
      # Employee choice to replace device

      # Degrade devices

      # Uit dienst treding (turnover/uitstroom)
      uitstroom = (t_start_employees * @odds[uitstroom]).round
      uitstroom.times do
        state[:employees].delete_at(rand(state.employees.length))
      end
      events[:uitstroom] = uitstroom

      # Return the updated state and events
      [state, events]
    end

    assert_in_delta(0.5, e[:instroom][:mean], 0.05)
    assert_in_delta(0.5, e[:uitstroom][:mean], 0.05)
  end

  def test_init
  end
end
