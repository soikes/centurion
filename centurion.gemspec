lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'centurion/version'

Gem::Specification.new do |spec|
  spec.name          = 'centurion'
  spec.version       = Centurion::VERSION
  spec.authors       = ['Mike Soikkeli']
  spec.email         = ['mike@soikke.li']

  spec.summary       = %q{create and command an army of virtual machines}
  spec.homepage      = 'https://github.com/soikes/centurion'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'faker', '~> 1.8'

  spec.add_runtime_dependency 'activesupport', '~> 5.1'
  spec.add_runtime_dependency 'net-scp', '~> 1.2'
  spec.add_runtime_dependency 'net-ssh', '~> 4.2'
  spec.add_runtime_dependency 'rbvmomi', '~> 1.11'
end
