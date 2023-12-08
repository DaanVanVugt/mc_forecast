# mc_forecast

[![Gem Version](https://img.shields.io/gem/v/mc_forecast)](https://rubygems.org/gems/mc_forecast)
[![Gem Downloads](https://img.shields.io/gem/dt/mc_forecast)](https://www.ruby-toolbox.com/projects/mc_forecast)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/DaanVanVugt/ruby-mc/ci.yml)](https://github.com/DaanVanVugt/ruby-mc/actions/workflows/ci.yml)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/DaanVanVugt/ruby-mc)](https://codeclimate.com/github/DaanVanVugt/ruby-mc)

Use Monte-Carlo methods for business forecasting. Define transition methods (for example a month-based one) and keep track of events you are interested in. Automatically generates a 95% confidence interval and mean values.

---

- [Quick start](#quick-start)
- [Support](#support)
- [License](#license)
- [Code of conduct](#code-of-conduct)
- [Contribution guide](#contribution-guide)

## Quick start

```
gem install mc_forecast
```

```ruby
require "mc_forecast"
# all arguments optional
e = McForecast::Simulation.new.run(init_state: nil, steps: 1, trials: 1_000) do |_state, _step, _trial|
  events = {}
  events[:coin] = rand > 0.5 ? 1 : 0

  # block should return a new state and a hash of events
  [nil, events]
end
# e[:coin][:mean][0] ~ 0.5
# e[:coin][:quantiles][0.025][0] ~ 0
# e[:coin][:quantiles][0.975][0] ~ 1
```

## Support

If you want to report a bug, or have ideas, feedback or questions about the gem, [let me know via GitHub issues](https://github.com/DaanVanVugt/ruby-mc/issues/new) and I will do my best to provide a helpful answer. Happy hacking!

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Code of conduct

Everyone interacting in this project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).

## Contribution guide

Pull requests are welcome!
