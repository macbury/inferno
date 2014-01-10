# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inferno/version'

Gem::Specification.new do |spec|
  spec.name          = "inferno"
  spec.version       = Inferno::VERSION
  spec.authors       = ["Arkadiusz Buras"]
  spec.email         = ["macbury@gmail.com"]
  spec.summary       = "Gem gives object the ability to bind and trigger custom named events. Events do not have to be declared before they are bound, and may take passed arguments. "
  spec.homepage      = "http://macbury.pl"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency "eventmachine"
end
