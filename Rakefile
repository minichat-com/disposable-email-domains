# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "set"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Collect domains removed from domains.txt since BASE_REF (default: master) and append to deleted_domains.txt"
task :collect_deleted_domains do
  base_ref = ENV.fetch("BASE_REF", "master")

  base_domains = `git show #{base_ref}:domains.txt 2>/dev/null`.split("\n").to_set
  if base_domains.empty?
    abort "Could not read domains.txt from ref '#{base_ref}'"
  end

  current_domains = File.read("domains.txt").split("\n").to_set

  removed = base_domains - current_domains

  existing = File.exist?("deleted_domains.txt") ? File.read("deleted_domains.txt").split("\n").to_set : Set.new
  new_deletions = removed - existing

  if new_deletions.empty?
    puts "No new deleted domains found since #{base_ref}."
  else
    updated = (existing | new_deletions).sort
    File.write("deleted_domains.txt", updated.join("\n") + "\n")
    puts "Added #{new_deletions.size} domain(s) to deleted_domains.txt (#{updated.size} total)"
  end
end

task default: %i[test rubocop]
