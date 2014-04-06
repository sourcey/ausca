# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ausca/version'

Gem::Specification.new do |spec|
  spec.name          = "ausca"
  spec.version       = Ausca::VERSION
  spec.authors       = ["Kam Low"]
  spec.email         = ["hello@sourcey.com"]
  spec.description   = %q{Ausca is a collection of automation utilities that you can use to fast-track the development of your online empire.}
  spec.summary       = %q{Automation utilities and bots.}
  spec.homepage      = "http://ausca.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "twitter", "~> 5.8.0"
end
