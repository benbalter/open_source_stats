# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'open_source_stats/version'

Gem::Specification.new do |spec|
  spec.name          = "open_source_stats"
  spec.version       = OpenSourceStats::VERSION
  spec.authors       = ["Ben Balter"]
  spec.email         = ["ben.balter@github.com"]
  spec.summary       = %q{A quick script to generate metrics about the contribution your organization makes to the open source community in a 24-hour period}
  spec.homepage      = "https://github.com/benbalter/open_source_stats"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "octokit"
  spec.add_dependency "dotenv"
  spec.add_dependency "activesupport"
  spec.add_dependency "terminal-table"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
