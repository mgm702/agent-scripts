#!/usr/bin/env ruby
# Creates symlinks from ~/.claude/skills/ to each skill in this repo.
# Run this on any new machine after cloning agent-scripts.

require 'fileutils'

SKILLS_SRC  = File.expand_path('../skills', __dir__)
SKILLS_DEST = File.expand_path('~/.claude/skills')

FileUtils.mkdir_p(SKILLS_DEST)

skills = Dir.entries(SKILLS_SRC).reject { |e| e.start_with?('.') }.sort

skills.each do |skill|
  src = File.join(SKILLS_SRC, skill, 'SKILL.md')
  next unless File.exist?(src)

  skill_dir = File.join(SKILLS_DEST, skill)
  dest      = File.join(skill_dir, 'SKILL.md')

  FileUtils.mkdir_p(skill_dir)

  if File.symlink?(dest)
    puts "~ #{skill} (already linked, skipping)"
  elsif File.exist?(dest)
    puts "! #{skill} (real file exists at destination, skipping)"
  else
    File.symlink(src, dest)
    puts "+ #{skill}"
  end
end

puts ''
puts "Done. #{skills.length} skills available at #{SKILLS_DEST}"
