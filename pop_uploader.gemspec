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
  spec.bindir        = "bin"
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables   = ['pop']
  spec.require_paths = ["lib"]

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
