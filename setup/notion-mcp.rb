#!/usr/bin/env ruby
# Sets up the Notion MCP server for Claude Code on any machine.
# Prerequisites: create an integration at notion.so/profile/integrations
#                and connect it to your Plans parent page.

require 'json'
require 'fileutils'

SETTINGS_PATH = File.expand_path('~/.claude/settings.json')

def prompt(message)
  print message
  $stdout.flush
  gets.chomp.strip
end

puts 'Notion MCP setup for Claude Code'
puts '---------------------------------'
puts '1. Go to notion.so/profile/integrations → create internal integration'
puts '2. Open your Plans parent page → ... → Connections → add integration'
puts '3. Copy the page ID from the URL: notion.so/workspace/Page-Name-<PAGE_ID>'
puts ''

notion_token = prompt('Notion integration token (ntn_...): ')
abort 'Error: token required' if notion_token.empty?

plans_parent_id = prompt('Plans parent page ID: ')
abort 'Error: parent page ID required' if plans_parent_id.empty?

mcp_entry = {
  'command' => 'npx',
  'args' => ['-y', '@notionhq/notion-mcp-server'],
  'env' => { 'NOTION_TOKEN' => notion_token }
}

FileUtils.mkdir_p(File.dirname(SETTINGS_PATH))

settings = File.exist?(SETTINGS_PATH) ? JSON.parse(File.read(SETTINGS_PATH)) : {}
settings['mcpServers'] ||= {}
settings['mcpServers']['notion'] = mcp_entry

File.write(SETTINGS_PATH, JSON.pretty_generate(settings))
puts ''
puts "✓ #{SETTINGS_PATH} updated"

puts ''
puts 'Add this to your project MEMORY.md:'
puts ''
puts '  ## Notion'
puts "  - Plans parent page ID: #{plans_parent_id}"
puts ''
puts 'Then restart Claude Code to activate the Notion MCP server.'
