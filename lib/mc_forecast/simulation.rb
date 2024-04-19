require "deep_dup"

module McForecast
  class Simulation
    def run(init_state: nil, trials: 1_000, steps: 1, quantiles: [0.025, 0.16, 0.84, 0.975], ranges: [])
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
      analyze(events, quantiles, ranges)
    end

    private

    # Return an analysis of the events, containing:
    # { event_name:
    #   {
    #     ranges: {
    #       0..12: { mean: ..., quantiles: { 0.025: ..., 0.975: ... }},
    #       13..24: { mean: ..., quantiles: { 0.025: ..., 0.975: ... }},
    #       ...
    #     },
    #     sum: { mean: ..., quantiles: { 0.025: ..., 0.975: ... }},
    #     mean: [...], # per step
    #     quantiles:
    #      { 0.025: [...],
    #        0.975: [...]
    # }}}
    def analyze(events, quantiles, ranges)
      events.transform_values do |steps| # array(steps) of arrays(trials)
        {
          ranges: analyze_ranges(steps, quantiles, ranges),
          sum: sum(steps, quantiles),
          # besides the total sum we may want to have a sum for multiples of our base period
          # (or week/month/quarter/year but that gets a bit complicated)
          mean: steps.map { |trials| (trials.sum || 0).to_f / trials.length },
          quantiles: quantiles.zip(step_quantiles(quantiles, steps)).to_h
        }
      end
    end

    def analyze_ranges(steps, quantiles, ranges) # rubocop:disable Metrics/AbcSize
      ranges.each_with_object({}) do |range, results|
        range_sums = steps.slice(range).transpose.map(&:sum)

        results[range] = {
          mean: range_sums.sum.to_f / range_sums.length,
          quantiles: quantiles.zip(
            quantiles.map do |q|
              range_sums.sort[(q * (range_sums.length - 1)).round.clamp(0, range_sums.length - 1)]
            end
          ).to_h
        }
      end
    end

    def sum(steps, quantiles)
      sums = steps.transpose.map(&:sum) # gives a sum of this event, per trial
      {
        mean: (sums.sum || 0).to_f / steps[0].length,
        # sort all of the sums, and take the elements closest to the chosen quantiles, and then make a nice hash
        quantiles: quantiles.zip(sums.sort.values_at(*quantile_indices(steps[0].length, quantiles))).to_h
      }
    end

    def step_quantiles(quantiles, steps)
      if quantiles.any?
        # only need to sort if we request answers on any quantiles
        steps.map do |trials|
          # could avoid sorting with some creativity, but probably fine for our data lengths so far
          trials.sort.values_at(*quantile_indices(trials.length, quantiles))
        end.transpose # a[step][]
      else
        []
      end
    end

    def quantile_indices(count, quantiles)
      quantiles.map do |q|
        (q * (count - 1)).round.to_i.clamp(0, count - 1)
      end
    end
  end
end
