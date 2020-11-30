# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/standoc/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-standoc"
  spec.version       = Metanorma::Standoc::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "metanorma-standoc realises standards following the Metanorma standoc model"
  spec.description   = <<~DESCRIPTION
    metanorma-standoc realises standards following the Metanorma standoc model

    This gem is in active development.
  DESCRIPTION

  spec.homepage      = "https://github.com/metanorma/metanorma-standoc"
  spec.license       = "BSD-2-Clause"

  spec.bindir        = "bin"
  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_dependency "asciidoctor", "~> 2.0.0"
  spec.add_dependency "ruby-jing"
  spec.add_dependency "isodoc", "~> 1.3.0"
  spec.add_dependency "iev", "~> 0.2.1"
  spec.add_dependency "metanorma-plugin-datastruct"
  spec.add_dependency "metanorma-plugin-lutaml", "~> 0.2.1"
  # relaton-cli not just relaton, to avoid circular reference in metanorma
  spec.add_dependency "relaton-cli", "~> 1.7.0"
  spec.add_dependency "relaton-iev", "~> 1.1.0"
  spec.add_dependency "sterile", "~> 1.0.14"
  spec.add_dependency "concurrent-ruby"
  spec.add_dependency "unicode2latex", "~> 0.0.1"
  spec.add_dependency "mimemagic"
  spec.add_dependency "mathml2asciimath"
  spec.add_dependency "latexmath"
  spec.add_dependency "fontist", "~> 1.5.0"

  spec.add_development_dependency "byebug"
  spec.add_development_dependency "sassc", "2.4.0"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "= 0.54.0"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "vcr", "~> 5.0.0"
  spec.add_development_dependency "webmock"
end
