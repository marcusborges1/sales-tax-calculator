# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names', '--plugin', 'rubocop-rspec']
end

RuboCop::RakeTask.new('rubocop:autocorrect') do |task|
  task.options = ['--autocorrect', '--plugin', 'rubocop-rspec']
end

task default: :check

desc 'Run all checks (tests and linting)'
task check: %i[spec rubocop]
