# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[spec rubocop]

desc "Run all tests and checks"
task ci: %i[spec rubocop]

desc "Open an IRB session with the gem loaded"
task :console do
  require "irb"
  require "agent_skills"
  ARGV.clear
  IRB.start(__FILE__)
end
