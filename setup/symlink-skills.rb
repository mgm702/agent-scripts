#!/usr/bin/env ruby
# Creates symlinks from $CLAUDE_CONFIG_DIR/skills/ (or ~/.claude/skills/) to each
# skill in this repo. Run this on any new machine after cloning agent-scripts.
#
# Usage:
#   ruby setup/symlink-skills.rb
#   CLAUDE_CONFIG_DIR=~/.claude-config/personal ruby setup/symlink-skills.rb

require 'fileutils'

SKILLS_SRC = File.expand_path('../skills', __dir__)

config_dir  = ENV['CLAUDE_CONFIG_DIR'] ? File.expand_path(ENV['CLAUDE_CONFIG_DIR']) : File.expand_path('~/.claude')
SKILLS_DEST = File.join(config_dir, 'skills')

puts "Using config dir: #{config_dir}"
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
