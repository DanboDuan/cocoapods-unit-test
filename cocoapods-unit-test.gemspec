# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-unit-test/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-unit-test'
  spec.version       = CocoapodsUnitTest::VERSION
  spec.authors       = ['bob']
  spec.email         = ['bob170731@gmail.com']
  spec.description   = %q{A short description of cocoapods-unit-test.}
  spec.summary       = %q{A longer description of cocoapods-unit-test.}
  spec.homepage      = 'https://github.com/DanboDuan/cocoapods-unit-test'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'xcodeproj','~> 1.10'
  spec.add_dependency 'cocoapods-core','~> 1.8'
  spec.add_dependency 'cocoapods','~> 1.8'
  spec.add_dependency 'xcpretty','~> 0.3'
  spec.add_dependency 'neatjson','~> 0.9'

  spec.add_development_dependency 'bundler', '>= 2.2.33'
  spec.add_development_dependency 'rake','>= 12.3.3'
end
