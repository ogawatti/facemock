# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'facemock/version'

Gem::Specification.new do |spec|
  spec.name          = "facemock"
  spec.version       = Facemock::VERSION
  spec.authors       = ["ogawatti"]
  spec.email         = ["ogawattim@gmail.com"]
  spec.description   = %q{This is facebook mock application for fb_graph.}
  spec.summary       = %q{This is facebook mock application for fb_graph.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 4.1.4"
  spec.add_dependency "sqlite3"
  spec.add_dependency "fb_graph"
  spec.add_dependency "hashie"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "coveralls"
end
