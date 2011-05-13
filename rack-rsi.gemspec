# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/rsi_version"

Gem::Specification.new do |s|
  s.name        = "rack-rsi"
  s.version     = Rack::RSI::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ram Singla"]
  s.email       = ["ram.singla@gmail.com"]
  s.homepage    = "https://github.com/ramsingla/rack-rsi"
  s.summary     = %q{Rack Middleware: Rack Side Include}
  s.description = %q{Rack Side Include helps you assemble pages like Edge Side Include (ESI) using ERB tags.}

  s.rubyforge_project = "rack-rsi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_rubygems_version = ">= 1.3.7"
  s.add_dependency "rack"
end
