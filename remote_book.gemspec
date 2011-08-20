# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "remote_book"

Gem::Specification.new do |s|
  s.name        = "remote_book"
  s.version     = RemoteBook::VERSION
  s.authors     = ["Seth Faxon"]
  s.email       = ["seth.faxon@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Pull book affiliate links and images from Amazon, Barns & Noble}
  s.description = %q{Pull book affiliate links and images from Amazon, Barns & Noble}

  s.rubyforge_project = "remote_book"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>)
    else
      s.add_dependency(%q<nokogiri>)
    end
  else
    s.add_dependency(%q<nokogiri>)
  end
end
