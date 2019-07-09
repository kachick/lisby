require './lib/lisby/version'

Gem::Specification.new do |gem|
  # specific

  gem.description   = %q{Tiny LISP interpreter}

  gem.summary       = gem.description.dup
  gem.homepage      = 'https://github.com/kachick/lisby'
  gem.license       = 'MIT'
  gem.name          = 'lisby'
  gem.version       = Lisby::VERSION.dup

  gem.required_ruby_version = '>= 2.5'

  gem.add_development_dependency 'rspec', '>= 3.8', '< 4'
  gem.add_development_dependency 'yard', '>= 0.9.20', '< 2'

  # common

  gem.authors       = ['Kenichi Kamiya']
  gem.email         = ['kachick1+ruby@gmail.com']
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
