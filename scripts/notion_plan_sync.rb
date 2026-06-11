#!/usr/bin/env ruby
# frozen_string_literal: true

# notion_plan_sync.rb
#
# Syncs *-plan.md files to Notion using the direct Notion REST API.
#
# Modes:
#   Stop hook  — called by Claude Code after each turn; reads JSON from stdin,
#                detects modified *-plan.md files via git diff, syncs each one.
#   Direct     — ruby notion_plan_sync.rb path/to/plan.md
#
# Env vars:
#   NOTION_TOKEN — Notion integration token (required)

require 'net/http'
require 'json'
require 'uri'
require 'fileutils'

NOTION_API = 'https://api.notion.com/v1'
NOTION_VERSION = '2022-06-28'

# Project parent page IDs in Notion
PROJECT_PARENTS = {
  'hatchfinder'   => '34f99752-5e1d-81c1-9b0a-e6b17ac27e86',
  'agent-scripts' => '34f99752-5e1d-81f5-aca7-e852b7e7d902',
  'odds-api'      => '34f99752-5e1d-8102-be9d-fddd20dfd3e7',
  'scaffold'      => '34f99752-5e1d-8186-9dc0-cc37af76f5db',
}.freeze

FALLBACK_PARENT = '34c99752-5e1d-8041-8385-f055f1cb7f55'

MAX_RICH_TEXT = 2000
MAX_BLOCKS_PER_REQUEST = 100

# ── Notion API helpers ─────────────────────────────────────────────────────────

def token
  ENV['NOTION_TOKEN'] or abort('NOTION_TOKEN env var not set')
end

def notion_request(method, path, body = nil)
  uri = URI("#{NOTION_API}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  klass = { 'GET' => Net::HTTP::Get, 'POST' => Net::HTTP::Post,
            'PATCH' => Net::HTTP::Patch, 'DELETE' => Net::HTTP::Delete }[method]
  req = klass.new(uri)
  req['Authorization'] = "Bearer #{token}"
  req['Notion-Version'] = NOTION_VERSION
  req['Content-Type'] = 'application/json'
  req.body = body.to_json if body

  res = http.request(req)
  JSON.parse(res.body)
end

def create_page(parent_id, title, blocks)
  body = {
    parent: { page_id: parent_id },
    properties: { title: { title: [{ text: { content: title } }] } },
    children: blocks.first(MAX_BLOCKS_PER_REQUEST)
  }
  page = notion_request('POST', '/pages', body)
  page_id = page['id']

  # Append remaining blocks in batches
  blocks.drop(MAX_BLOCKS_PER_REQUEST).each_slice(MAX_BLOCKS_PER_REQUEST) do |batch|
    notion_request('PATCH', "/blocks/#{page_id}/children", { children: batch })
  end

  page
end

def update_page_content(page_id, blocks)
  # Delete all existing child blocks
  children = notion_request('GET', "/blocks/#{page_id}/children?page_size=100")
  (children['results'] || []).each do |block|
    notion_request('DELETE', "/blocks/#{block['id']}")
  end

  # Append new blocks in batches
  blocks.each_slice(MAX_BLOCKS_PER_REQUEST) do |batch|
    notion_request('PATCH', "/blocks/#{page_id}/children", { children: batch })
  end
end

def archive_page(page_id)
  notion_request('PATCH', "/pages/#{page_id}", { archived: true })
end

# ── Markdown → Notion blocks ───────────────────────────────────────────────────

def rich_text(text)
  text.scan(/.{1,#{MAX_RICH_TEXT}}/m).map { |chunk| { text: { content: chunk } } }
end

def code_block(code, lang)
  { type: 'code',
    code: { rich_text: rich_text(code.strip), language: lang.empty? ? 'plain text' : lang } }
end

def heading_block(level, text)
  type = "heading_#{level}"
  { type => { rich_text: rich_text(text) }, type: type }
end

def to_do_block(text, checked)
  { type: 'to_do', to_do: { rich_text: rich_text(text), checked: checked } }
end

def bullet_block(text)
  { type: 'bulleted_list_item',
    bulleted_list_item: { rich_text: rich_text(text) } }
end

def numbered_block(text)
  { type: 'numbered_list_item',
    numbered_list_item: { rich_text: rich_text(text) } }
end

def paragraph_block(text)
  { type: 'paragraph', paragraph: { rich_text: rich_text(text) } }
end

def divider_block
  { type: 'divider', divider: {} }
end

def parse_markdown(md)
  # Strip YAML front matter
  md = md.sub(/\A---\n.*?\n---\n/m, '')

  blocks = []
  lines = md.lines
  i = 0

  while i < lines.length
    line = lines[i].rstrip

    # Code fence
    if line =~ /^```(\w*)/
      lang = $1
      code_lines = []
      i += 1
      while i < lines.length && lines[i].rstrip !~ /^```\s*$/
        code_lines << lines[i]
        i += 1
      end
      blocks << code_block(code_lines.join, lang)
      i += 1
      next
    end

    # Headings
    if (m = line.match(/^(\#{1,3})\s+(.*)/))
      blocks << heading_block(m[1].length, m[2])
      i += 1
      next
    end

    # Horizontal rule / divider
    if line =~ /^---+\s*$/
      blocks << divider_block
      i += 1
      next
    end

    # Checkboxes
    if (m = line.match(/^- \[(x| )\]\s+(.*)/i))
      blocks << to_do_block(m[2], m[1].downcase == 'x')
      i += 1
      next
    end

    # Bulleted list
    if (m = line.match(/^[-*]\s+(.*)/))
      blocks << bullet_block(m[1])
      i += 1
      next
    end

    # Numbered list
    if (m = line.match(/^\d+\.\s+(.*)/))
      blocks << numbered_block(m[1])
      i += 1
      next
    end

    # Blockquote → paragraph with > prefix
    if (m = line.match(/^>\s*(.*)/))
      blocks << paragraph_block("> #{m[1]}")
      i += 1
      next
    end

    # Table rows → paragraph (simple passthrough)
    if line =~ /^\|/
      blocks << paragraph_block(line)
      i += 1
      next
    end

    # Blank line
    if line.empty?
      i += 1
      next
    end

    # Plain paragraph
    blocks << paragraph_block(line)
    i += 1
  end

  blocks
end

# ── YAML front matter ──────────────────────────────────────────────────────────

def read_front_matter(content)
  return {} unless content.start_with?("---\n")

  fm_end = content.index("\n---\n", 4)
  return {} unless fm_end

  fm_text = content[4..fm_end]
  result = {}
  fm_text.each_line do |line|
    k, v = line.strip.split(/:\s+/, 2)
    result[k] = v if k && v
  end
  result
end

def write_front_matter(path, page_id, page_url)
  content = File.read(path)

  new_fm = "---\nnotion_page_id: #{page_id}\nnotion_page_url: #{page_url}\n---\n"

  if content.start_with?("---\n")
    fm_end = content.index("\n---\n", 4)
    if fm_end
      rest = content[(fm_end + 5)..]
      File.write(path, new_fm + rest)
    else
      File.write(path, new_fm + content)
    end
  else
    File.write(path, new_fm + content)
  end
end

# ── Project routing ────────────────────────────────────────────────────────────

def parent_for(file_path)
  PROJECT_PARENTS.each do |key, id|
    return id if file_path.include?(key)
  end
  FALLBACK_PARENT
end

def page_title(file_path)
  basename = File.basename(file_path, '.md')
  # e.g. hatchfinder-alerts-polish-plan → Alerts Polish Plan
  parts = basename.split('-')
  # Drop project name prefix (first word) and trailing "plan"
  parts = parts.drop(1)
  parts = parts[0..-2] if parts.last == 'plan'
  parts.map(&:capitalize).join(' ')
end

# ── Sync a single plan file ────────────────────────────────────────────────────

def sync_file(path)
  unless File.exist?(path)
    warn "notion_plan_sync: file not found: #{path}"
    return
  end

  content = File.read(path)
  fm = read_front_matter(content)
  blocks = parse_markdown(content)

  if blocks.empty?
    warn "notion_plan_sync: no blocks parsed from #{path}, skipping"
    return
  end

  existing_id = fm['notion_page_id']

  if existing_id && !existing_id.empty?
    puts "notion_plan_sync: updating page #{existing_id} for #{File.basename(path)}"
    update_page_content(existing_id, blocks)
  else
    parent_id = parent_for(path)
    title = page_title(path)
    puts "notion_plan_sync: creating page '#{title}' under #{parent_id}"
    page = create_page(parent_id, title, blocks)
    page_id = page['id']
    page_url = page['url']
    write_front_matter(path, page_id, page_url)
    puts "notion_plan_sync: created #{page_url}"
  end
end

# ── Entry point ────────────────────────────────────────────────────────────────

if ARGV.any?
  # Direct mode: sync each file passed as argument
  ARGV.each { |f| sync_file(File.expand_path(f)) }
else
  # Stop hook mode: read JSON from stdin, detect changed plan files
  input = $stdin.read
  begin
    _event = JSON.parse(input)
  rescue JSON::ParseError
    # Not JSON — may have been invoked directly without args; exit silently
    exit 0
  end

  # Find plan files modified since last commit in any known project dir
  changed = `git -C ~ diff --name-only HEAD 2>/dev/null`.lines.map(&:strip)

  # Also check common project roots for uncommitted changes
  project_roots = Dir.glob(File.expand_path('~/code/projects/*/'))
  plan_files = []

  project_roots.each do |root|
    out = `git -C #{root} diff --name-only HEAD 2>/dev/null`
    out.each_line do |rel|
      rel = rel.strip
      next unless rel.end_with?('-plan.md')
      abs = File.join(root, rel)
      plan_files << abs if File.exist?(abs)
    end
  end

  # Also check staged files
  project_roots.each do |root|
    out = `git -C #{root} diff --cached --name-only 2>/dev/null`
    out.each_line do |rel|
      rel = rel.strip
      next unless rel.end_with?('-plan.md')
      abs = File.join(root, rel)
      plan_files << abs if File.exist?(abs)
    end
  end

  plan_files.uniq.each { |f| sync_file(f) }
end
