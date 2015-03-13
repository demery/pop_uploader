# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pop_uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "pop_uploader"
  spec.version       = PopUploader::VERSION
  spec.authors       = ["Doug Emery"]
  spec.email         = ["emeryr@upenn.edu"]

  # if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  # end

  spec.summary       = %q{Upload stuff to POP's Flickr site.}
  spec.description   = %q{Upload stuff to POP's Flickr site.}
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # * axlsx (1.3.6)
  # * bundler (1.8.2)
  # * celluloid (0.16.0)
  # * coderay (1.1.0)
  # * diff-lcs (1.2.5)
  # * ffi (1.9.6)
  # * flickraw (0.9.8)
  # * formatador (0.2.5)
  # * guard (2.11.1)
  # * guard-compat (1.2.0)
  # * guard-rspec (4.5.0)
  # * hitimes (1.2.2)
  # * htmlentities (4.3.3)
  # * listen (2.8.5)
  # * lumberjack (1.0.9)
  # * method_source (0.8.2)
  # * mini_portile (0.6.2)
  # * nenv (0.1.1)
  # * nokogiri (1.6.6.2)
  # * notiffany (0.0.3)
  # * pry (0.10.1)
  # * rb-fsevent (0.9.4)
  # * rb-inotify (0.9.5)
  # * roo (2.0.0 707ed15)
  # * rspec (3.2.0)
  # * rspec-core (3.2.0)
  # * rspec-expectations (3.2.0)
  # * rspec-mocks (3.2.0)
  # * rspec-support (3.2.1)
  # * rubyzip (1.1.7)
  # * shellany (0.0.1)
  # * slop (3.6.0)
  # * thor (0.19.1)
  # * timers (4.0.1)
  # * zip-zip (0.3)

  spec.add_dependency 'flickraw', '~> 0.9.8'
  spec.add_dependency 'roo', '~> 1.13.2'
  spec.add_dependency 'axlsx', '~> 1.3.6'
  spec.add_dependency 'zip-zip', '~> 0.3'
  spec.add_dependency 'configatron', '~> 4.5.0'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry', '~> 0.10.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.5.0'
  spec.add_development_dependency 'rb-fsevent', '~> 0.9.4' if `uname` =~ /Darwin/
end
