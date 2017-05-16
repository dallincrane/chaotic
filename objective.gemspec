# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name        = 'objective'
  s.version     = '1.0.0'
  s.date        = '2017-03-21'
  s.summary     = 'Business Logic Bliss'
  s.description = 'functional classes with param validations for cautious developers'
  s.authors     = ['Dallin Crane']
  s.homepage    = 'https://github.com/dallincrane/objective'

  s.files         = Dir['lib/**/*'].keep_if { |file| File.file?(file) }
  s.test_files    = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.add_runtime_dependency 'activesupport', '~> 5.0'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
end
