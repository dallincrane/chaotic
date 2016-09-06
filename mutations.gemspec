# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name        = 'chaotic'
  s.version     = '0.0.0'
  s.date        = '2016-09-01'
  s.summary     = 'Business Logic Bliss'
  s.description = 'incremental strong params and validations for paranoid developers'
  s.authors     = ['Dallin Crane']
  s.email       = 'dallin@objectiveinc.com'
  s.homepage    = 'https://bitbucket.org/agencyfusion/chaotic'

  s.files         = Dir['lib/**/*'].keep_if { |file| File.file?(file) }
  s.test_files    = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.add_runtime_dependency 'activesupport', '~> 4.2'

  s.add_development_dependency 'minitest', '~> 4'
  s.add_development_dependency 'rake'
end
