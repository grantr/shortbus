# -*- encoding: utf-8 -*-
require File.expand_path('../lib/shortbus/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Grant Rodgers"]
  gem.email         = ["grantr@gmail.com"]
  gem.description   = %q{Shortbus is a replication and snapshot service similar to Linkedin's Databus.}
  gem.summary       = %q{Replication and snapshot service}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "shortbus"
  gem.require_paths = ["lib"]
  gem.version       = Shortbus::VERSION

  gem.add_runtime_dependency "celluloid"
  gem.add_runtime_dependency "reel"
  gem.add_runtime_dependency "octarine"
  gem.add_runtime_dependency "multi_json", [">= 1.3"]
  gem.add_runtime_dependency "leveldb-ruby"
end
