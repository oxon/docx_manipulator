# -*- coding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "docx_manipulator/version"

Gem::Specification.new do |s|
  s.name        = "docx_manipulator"
  s.version     = DocxManipulator::VERSION
  s.authors     = ["Michael Stämpfli"]
  s.email       = ["michael.staempfli@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Enables the modification of docx files.}
  s.description = %q{This Gem enables you to modify the contents of docx files.}

  s.rubyforge_project = "docx_manipulator"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_dependency "rubyzip"
  s.add_dependency "nokogiri"
  s.add_dependency 'i18n'
end
