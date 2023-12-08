require_relative "lib/mc_forecast/version"

Gem::Specification.new do |spec|
  spec.name = "mc_forecast"
  spec.version = McForecast::VERSION
  spec.authors = ["Daan van Vugt"]
  spec.email = ["dvanvugt@ignitioncomputing.com"]

  spec.summary = "Forecast processes using monte-carlo simulation"
  spec.homepage = "https://github.com/DaanVanVugt/ruby-mc"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/DaanVanVugt/ruby-mc/issues",
    "changelog_uri" => "https://github.com/DaanVanVugt/ruby-mc/releases",
    "source_code_uri" => "https://github.com/DaanVanVugt/ruby-mc",
    "homepage_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[LICENSE.txt README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "deep_dup"
end
