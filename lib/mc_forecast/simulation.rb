module McForecast
  class Simulation
    def run(init_state: nil, trials: 1_000, steps: 1)
      events = {}
      1.upto(trials) do |trial|
        state = init_state
        1.upto(steps) do |step|
          state, e = yield state, step, trial
          e.each_pair do |k, v|
            events[k] ||= Array.new(steps)
            events[k][step] = (events[k][step] || 0) + v
          end
        end
      end
      events.transform_values! { |a| a[1,a.length].map { |v| Rational(v || 0, trials) } }
      events
    end
  end
end
