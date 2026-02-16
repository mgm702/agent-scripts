#!/usr/bin/env ruby
# frozen_string_literal: true

require "net/http"
require "uri"
require "nokogiri"
require "ruby-readability"
require "reverse_markdown"

MAX_REDIRECTS = 3
TIMEOUT = 15

def fetch(url, redirects = 0)
  raise "Too many redirects" if redirects > MAX_REDIRECTS

  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  http.open_timeout = TIMEOUT
  http.read_timeout = TIMEOUT

  response = http.get(uri.request_uri, {
    "User-Agent" => "Mozilla/5.0 (compatible; AgentScript/1.0)"
  })

  case response
  when Net::HTTPRedirection
    fetch(response["location"], redirects + 1)
  else
    response.body
  end
end

def extract_content(html)
  doc = Readability::Document.new(html)
  markdown = ReverseMarkdown.convert(doc.content, unknown_tags: :bypass)
  return markdown.strip unless markdown.strip.empty?

  # Fallback: strip noise, find main content
  page = Nokogiri::HTML(html)
  page.css("nav, header, footer, script, style, noscript, iframe").remove
  main = page.at_css("main") || page.at_css("article") || page.at_css("body")
  ReverseMarkdown.convert(main.to_html, unknown_tags: :bypass).strip
end

# --- CLI ---

url = ARGV[0]
if url.nil? || url.empty?
  puts "Usage: content.rb <url>"
  exit 1
end

html = fetch(url)
puts extract_content(html)
