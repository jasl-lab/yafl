# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "yafl/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "yafl"
  s.version     = YAFL::VERSION
  s.authors     = ["jasl"]
  s.email       = ["jasl9187@hotmail.com"]
  s.homepage    = "https://github.com/jasl-lab/yafl"
  s.summary     = "YAFL - Yet Another Formula Language."
  s.description = <<-TEXT.lstrip
    YAFL - Yet Another Formula Language
  TEXT
  s.license = "MIT"

  s.add_development_dependency "minitest"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop"

  s.files        = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files   = Dir["test/*_test.rb"]
  s.require_path = "lib"
end
