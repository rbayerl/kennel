# frozen_string_literal: true
require "bundler/setup"
require "bundler/gem_tasks"
require "bump/tasks"

require "rubocop/rake_task"
RuboCop::RakeTask.new

desc "Run tests"
task :test do
  sh "forking-test-runner test --merge-coverage --quiet"
end

desc "Run integration tests"
task :integration do
  sh "ruby test/integration.rb"
end

desc "Keep readmes in sync"
task :readme do
  install = File.read("Readme.md")[/<!-- CUT.* -->.*<!-- CUT -->\n/m]
  template = File.read("template/Readme.md")
  template.sub!("## Structure", "#{install}\n## Structure")
  template.gsub!("(github/", "(template/github/")
  File.write("Readme.md", template)
  sh "git diff HEAD --exit-code -- Readme.md"
end

# make sure we always run what travis runs
require "yaml"
travis = YAML.load_file(".travis.yml").fetch("env").map { |v| v.delete("TASK=") }
raise if travis.empty?
task default: travis
