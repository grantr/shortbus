# -*- encoding: utf-8 -*-
require File.expand_path('../lib/borg/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Grant Rodgers"]
  gem.email         = ["grantr@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "borg"
  gem.require_paths = ["lib"]
  gem.version       = Borg::VERSION

  gem.add_runtime_dependency "celluloid"
  gem.add_runtime_dependency "reel"
  gem.add_runtime_dependency "octarine"
  gem.add_runtime_dependency "multi_json", [">= 1.3"]
end
