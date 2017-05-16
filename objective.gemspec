# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name          = 'objective'
  s.version       = '1.0.0'
  s.date          = '2017-05-16'
  s.summary       = 'Business Logic Units'
  s.description   = 'functional classes with param validations for cautious developers'
  s.authors       = ['Dallin Crane']
  s.homepage      = 'https://github.com/dallincrane/objective'
  s.files         = Dir['lib/**/*'].keep_if { |file| File.file?(file) }
  s.test_files    = Dir['spec/**/*']
  s.require_paths = ['lib']
  s.license       = 'MIT'

  s.add_runtime_dependency 'activesupport', '~> 5.0'

  s.add_development_dependency 'byebug', '~> 9.0'
  s.add_development_dependency 'minitest', '~> 5.10'
  s.add_development_dependency 'rake', '~> 12.0'
end
