# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.warning = true
end

task default: :test
