lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'nanoc-conref-fs'
  spec.version       = '0.6.1'
  spec.authors       = ['Garen Torikian']
  spec.email         = ['gjtorikian@gmail.com']
  spec.summary       = 'A Nanoc filesystem to permit using conrefs/reusables in your content.'
  spec.homepage      = 'https://github.com/gjtorikian/nanoc-conref-fs'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'nanoc', '~> 4.0'
  spec.add_runtime_dependency 'activesupport', '~> 4.2'
  spec.add_runtime_dependency 'liquid', '~> 3.0'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '~> 5.8'
  spec.add_development_dependency 'awesome_print'
end
