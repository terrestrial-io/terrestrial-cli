# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'terrestrial/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "terrestrial-cli"
  spec.version       = Terrestrial::Cli::VERSION
  spec.authors       = ["Niklas Begley"]
  spec.email         = ["nik@terrestrial.io"]

  spec.summary       = %q{Ruby CLI Gem for interacting with your project and Terrestrial.}
  spec.description   = %q{Ruby CLI Gem for interacting with your project and Terrestrial.}
  spec.homepage      = "https://github.com/terrestrial-io/terrestrial-cli"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   << 'terrestrial'
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'terminal-table', '~> 1.5.2'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec_junit_formatter", "0.2.2"
end
