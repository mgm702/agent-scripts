#!/usr/bin/env ruby
# frozen_string_literal: true

require "net/http"
require "uri"
require "nokogiri"
require "optparse"

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

def search_ddg(query, num_results)
  uri = URI("https://lite.duckduckgo.com/lite/")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = TIMEOUT
  http.read_timeout = TIMEOUT

  response = http.post(uri.request_uri, URI.encode_www_form(q: query), {
    "Content-Type" => "application/x-www-form-urlencoded",
    "User-Agent" => "Mozilla/5.0 (compatible; AgentScript/1.0)"
  })

  doc = Nokogiri::HTML(response.body)
  results = []

  doc.css("table")[-1]&.css("tr")&.each_slice(4) do |rows|
    next if rows.any? { |r| r["class"]&.include?("result-sponsored") }

    link_el = rows.flat_map { |r| r.css("a.result-link") }.first
    snippet_el = rows.flat_map { |r| r.css("td.result-snippet") }.first

    next unless link_el

    href = link_el["href"]&.strip
    title = link_el.text.strip
    snippet = snippet_el&.text&.strip || ""

    next if href.nil? || href.empty?

    results << { title: title, url: href, snippet: snippet }
    break if results.size >= num_results
  end

  results
end

def fetch_content(url)
  require "ruby-readability"
  require "reverse_markdown"

  html = fetch(url)
  return nil unless html

  doc = Readability::Document.new(html)
  markdown = ReverseMarkdown.convert(doc.content, unknown_tags: :bypass)
  markdown.strip[0, 5000]
rescue => e
  "(content extraction failed: #{e.message})"
end

# --- CLI ---

num = 5
include_content = false

parser = OptionParser.new do |opts|
  opts.banner = "Usage: search.rb [options] <query>"
  opts.on("-n NUM", Integer, "Number of results (default: 5)") { |n| num = n }
  opts.on("--content", "Fetch and include page content") { include_content = true }
end
parser.parse!

query = ARGV.join(" ")
if query.empty?
  puts parser.help
  exit 1
end

results = search_ddg(query, num)

if results.empty?
  puts "No results found."
  exit 0
end

results.each_with_index do |r, i|
  puts "## #{i + 1}. #{r[:title]}"
  puts r[:url]
  puts r[:snippet] unless r[:snippet].empty?

  if include_content
    puts "\n### Content\n\n"
    puts fetch_content(r[:url])
  end

  puts "\n---\n\n"
end
