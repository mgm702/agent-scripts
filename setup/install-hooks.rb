#!/usr/bin/env ruby
# Installs agent-scripts hooks into $CLAUDE_CONFIG_DIR/settings.json (or
# ~/.claude/settings.json). Idempotent — re-running updates in place.
# Run this on any new machine after cloning agent-scripts.
#
# Usage:
#   ruby setup/install-hooks.rb
#   CLAUDE_CONFIG_DIR=~/.claude-config/personal ruby setup/install-hooks.rb

require 'json'
require 'fileutils'

REPO         = File.expand_path('..', __dir__)
HOOK_SCRIPT  = File.join(REPO, 'hooks', 'coding_standards.rb')
HOOK_COMMAND = "ruby #{HOOK_SCRIPT}"

config_dir    = ENV['CLAUDE_CONFIG_DIR'] ? File.expand_path(ENV['CLAUDE_CONFIG_DIR']) : File.expand_path('~/.claude')
settings_path = File.join(config_dir, 'settings.json')

puts "Using config dir: #{config_dir}"
FileUtils.mkdir_p(config_dir)

settings =
  if File.exist?(settings_path)
    JSON.parse(File.read(settings_path))
  else
    {}
  end

settings['hooks'] ||= {}
settings['hooks']['PreToolUse'] ||= []
pre = settings['hooks']['PreToolUse']

# Match any prior coding-standards entry — the script-based command OR an
# earlier inline `echo` version (matched on the injected marker text) — so we
# replace it rather than adding a duplicate.
entry = pre.find do |e|
  Array(e['hooks']).any? do |h|
    cmd = h['command'].to_s
    cmd.include?('coding_standards.rb') || cmd.include?('CODING STANDARDS')
  end
end

new_entry = {
  'matcher' => 'Edit|Write',
  'hooks'   => [
    { 'type' => 'command', 'command' => HOOK_COMMAND, 'suppressOutput' => true }
  ]
}

if entry
  entry.replace(new_entry)
  puts '~ coding-standards PreToolUse hook (updated)'
else
  pre << new_entry
  puts '+ coding-standards PreToolUse hook (added)'
end

File.write(settings_path, JSON.pretty_generate(settings) + "\n")

puts ''
puts "Done. Hook wired into #{settings_path}"
puts 'Open /hooks once (or restart Claude Code) to reload config.'
