#!/usr/bin/env ruby
# Stop hook: lints all git-modified files after each Claude turn

require "json"
require "open3"
require "shellwords"

SKIP_PATTERNS = %w[vendor/ node_modules/ .min. _generated .lock tmp/].freeze

def project_root(file)
  dir = File.dirname(File.expand_path(file))
  stdout, = Open3.capture2("git", "-C", dir, "rev-parse", "--show-toplevel")
  stdout.strip.empty? ? dir : stdout.strip
rescue StandardError
  dir
end

def skip?(file)
  SKIP_PATTERNS.any? { |pat| file.include?(pat) } || !File.file?(file)
end

def modified_files
  stdout, = Open3.capture2("git", "diff", "--name-only", "HEAD")
  untracked, = Open3.capture2("git", "ls-files", "--others", "--exclude-standard")
  (stdout.lines + untracked.lines).map(&:strip).reject(&:empty?)
end

def custom_cmd(root, ext)
  config_path = File.join(root, ".lint-config.json")
  return nil unless File.exist?(config_path)

  config = JSON.parse(File.read(config_path))
  config.dig("languages", ".#{ext}", "cmd")
rescue JSON::ParserError
  nil
end

def report_violations(label, output)
  puts "[lint-on-save] #{label}: unfixable violations remain:"
  puts output
  exit 1
end

def lint_ruby(file, root)
  bin = if File.exist?(File.join(root, "Gemfile")) &&
           File.read(File.join(root, "Gemfile")).include?("rubocop")
    "bundle exec rubocop"
  elsif system("which rubocop > /dev/null 2>&1")
    "rubocop"
  else
    puts "[lint-on-save] rubocop not found, skipping #{file}"
    return
  end

  system("cd #{root.shellescape} && #{bin} --autocorrect #{file.shellescape} > /dev/null 2>&1")
  stdout, stderr, status = Open3.capture3("cd #{root.shellescape} && #{bin} #{file.shellescape}")
  output = [stdout, stderr].reject(&:empty?).join("\n")
  report_violations(file, output) unless status.success?
end

def lint_go(file, _root)
  unless system("which gofmt > /dev/null 2>&1")
    puts "[lint-on-save] gofmt not found, skipping #{file}"
    return
  end

  system("gofmt -w #{file.shellescape}")

  return unless system("which golangci-lint > /dev/null 2>&1")

  dir = File.dirname(File.expand_path(file))
  system("golangci-lint run --fix #{dir}/... > /dev/null 2>&1")
  stdout, stderr, status = Open3.capture3("golangci-lint run #{dir}/...")
  output = [stdout, stderr].reject(&:empty?).join("\n")
  report_violations(file, output) unless status.success?
end

def lint_js(file, root)
  bin = if File.exist?(File.join(root, "node_modules/.bin/eslint"))
    File.join(root, "node_modules/.bin/eslint")
  elsif system("which eslint > /dev/null 2>&1")
    "eslint"
  else
    puts "[lint-on-save] eslint not found, skipping #{file}"
    return
  end

  system("#{bin} --fix #{file.shellescape} > /dev/null 2>&1")
  stdout, stderr, status = Open3.capture3("#{bin} #{file.shellescape}")
  output = [stdout, stderr].reject(&:empty?).join("\n")
  report_violations(file, output) unless status.success?
end

def lint_css(file, root)
  bin = File.join(root, "node_modules/.bin/stylelint")
  unless File.exist?(bin)
    puts "[lint-on-save] stylelint not found, skipping #{file}"
    return
  end

  system("#{bin} --fix #{file.shellescape} > /dev/null 2>&1")
end

modified_files.each do |file|
  next if skip?(file)

  ext = File.extname(file).delete_prefix(".")
  root = project_root(file)

  puts "[lint-on-save] #{file}"

  if (cmd = custom_cmd(root, ext))
    system(cmd.gsub("{{file}}", file))
    next
  end

  case ext
  when "rb"                     then lint_ruby(file, root)
  when "go"                     then lint_go(file, root)
  when "js", "jsx", "ts", "tsx" then lint_js(file, root)
  when "css", "scss"            then lint_css(file, root)
  end
end
