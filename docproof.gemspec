# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docproof/version'

Gem::Specification.new do |spec|
  spec.name          = "docproof"
  spec.version       = Docproof::VERSION
  spec.authors       = ["Ikhsan Maulana"]
  spec.email         = ["ixandidu@gmail.com"]

  spec.summary       = %q{Client library for Proof of Existence API}
  spec.description   = %q{Client library for Proof of Existence API}
  spec.homepage      = "https://github.com/ixandidu/docproof"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "webmock", "~> 2.3.2"
  spec.add_development_dependency "sinatra", "~> 1.4.8"
  spec.add_development_dependency "simplecov", "~> 0.13.0"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0.0"
end
