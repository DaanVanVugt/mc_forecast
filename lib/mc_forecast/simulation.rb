require "deep_dup"

module McForecast
  class Simulation
    def run(init_state: nil, trials: 1_000, steps: 1, quantiles: [0.025, 0.975])
      events = {}
      (0..trials - 1).each do |trial|
        state = DeepDup.deep_dup(init_state)
        (0..steps - 1).each do |step|
          state, e = yield state, step, trial
          e.each_pair do |k, v|
            # We explicitly store all the events, because we expect the block
            # to be relatively expensive this will not be so bad.
            # could replace with a quantile estimator like CKMS later
            events[k] ||= Array.new(steps) { Array.new(trials) }
            events[k][step][trial] = v
          end
        end
      end
      analyze(events, quantiles)
    end

    private

    # Return an analysis of the events, containing:
    # { event_name:
    #   { mean: [...], # per step
    #     quantiles:
    #      { 0.025: [...],
    #        0.975: [...]
    # }}}
    def analyze(events, quantiles)
      events.transform_values do |steps| # array(steps) of arrays(trials)
        a = if quantiles.any?
              # only need to sort if we request answers on any quantiles
              steps.map do |trials|
                # could avoid sorting with some creativity, but probably fine for our data lengths so far
                trials.sort.values_at(*quantile_indices(trials.length, quantiles))
              end.transpose # a[step][]
            else
              []
            end

        {
          mean: steps.map { |trials| Rational(trials.sum || 0, trials.length) },
          quantiles: quantiles.zip(a).to_h
        }
      end
    end

    def quantile_indices(n_trials, quantiles)
      quantiles.map do |q|
        (q * (n_trials - 1)).round.to_i.clamp(0, n_trials - 1)
      end
    end
  end
end
