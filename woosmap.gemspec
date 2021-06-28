# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'woosmap/version'

Gem::Specification.new do |s|
  s.name        = 'woosmap'
  s.license     = 'MIT'
  s.version     = Woos::Map::VERSION
  s.authors     = ['Mark Kampstra Reisbalans B.V.']
  s.email       = ['mark.kampstra@reisbalans.nl']
  s.homepage    = 'https://reisbalans.nl'
  s.summary     = 'Ruby wrapper for the WoosMap API'
  s.description = 'This is a ruby wrapper for the WoosMap api'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency('bundler', '> 1.0')
  s.add_development_dependency('coveralls', '~> 0.8')
  s.add_development_dependency('mocha', '~> 1.7.0')
  s.add_development_dependency('rake', '~> 12.3.2')
  s.add_development_dependency('rspec', '~> 3.9.0')
  s.add_development_dependency('rspec-collection_matchers', '~> 1.1')
  s.add_development_dependency('rspec-its', '~> 1.2')
  s.add_development_dependency('rubocop', '~> 0.79.0')
  s.add_development_dependency('simplecov', '~> 0.5')
  s.add_development_dependency('yard', '~> 0.9', '>= 0.9.11')
  s.add_dependency('hashie', '~> 3.6', '>= 3.6.0')
  s.add_dependency('httpclient', '~> 2.7', '>= 2.7.1')
  s.add_dependency('json', '>= 1.7.5')
  s.add_dependency('ruby-hmac', '~> 0.4.0')
end
