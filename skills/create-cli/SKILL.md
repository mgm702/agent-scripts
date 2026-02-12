# Create CLI

Design & scaffold distinctive, functional CLI tools.

## Patterns

- Standard `bin/` entry points
- Structure: Commands > Subcommands > Arguments > Flags
- Single entry file bootstraps command router
- Group related commands in subdirectories

## Style

- Minimal dependencies
- Prefer native `fs`, `path`, `child_process`
- Small libs ok: meow, picocolors, ora
- No heavy frameworks (commander ok if complexity warrants)

## Requirements

- Always provide `--help` with usage examples
- Always provide `--version` flag
- Exit codes: 0 success, 1 user error, 2 system error
- Stderr for errors, stdout for output
- Support `--quiet` and `--verbose` when applicable

## Output

- Default: human-readable
- Support `--json` for machine consumption
- Color output; respect `NO_COLOR` env var
- Progress indicators for long operations

## Testing

- Unit test command handlers separately from CLI parsing
- Integration test: spawn process, assert stdout/stderr/exit code
