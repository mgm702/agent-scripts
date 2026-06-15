#!/usr/bin/env ruby
# PreToolUse hook (Edit|Write): injects the coding-standards guardrails into
# context before every code edit. Wired up by setup/install-hooks.rb.
# See skills/coding-standards/SKILL.md for the full skill.

require 'json'

CONTEXT = 'CODING STANDARDS (see skills/coding-standards/SKILL.md). ' \
          'The four rules: 1) Do not make assumptions. Ask. ' \
          '2) Do not over-engineer. Match the existing complexity. ' \
          '3) Do not touch code you were not asked to touch. ' \
          '4) Do not invent libraries that do not exist.'

puts JSON.generate(
  hookSpecificOutput: {
    hookEventName: 'PreToolUse',
    additionalContext: CONTEXT
  }
)
