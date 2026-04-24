#!/usr/bin/env ruby
# Sets up the Notion MCP server for Claude Code on any machine.
# Prerequisites: create an integration at notion.so/profile/integrations
#                and connect it to your Plans parent page.

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

result = system(
  'claude', 'mcp', 'add', 'notion',
  '--scope', 'user',
  '-e', "NOTION_TOKEN=#{notion_token}",
  '--', 'npx', '-y', '@notionhq/notion-mcp-server'
)

abort 'Error: claude mcp add failed. Is Claude Code installed and in your PATH?' unless result

puts ''
puts '✓ Notion MCP server registered with Claude Code'
puts ''
puts 'Add this to your project MEMORY.md:'
puts ''
puts '  ## Notion'
puts "  - Plans parent page ID: #{plans_parent_id}"
puts ''
puts 'Run `claude mcp list` to verify the server is connected.'
