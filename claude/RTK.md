# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

Only the literal top-level command is rewritten. A command run through a shell
function, `xargs`, or a nested `bash -c` reaches the real binary unfiltered — so
those are not an rtk measurement, and results from them do not reflect rtk.

### grep needs `-r`

`rtk grep` renders matches only when `-r` is present. Without it — one file,
several files, or a glob — output collapses to a bare count and no matches:

```bash
grep -n PATTERN path/to/file.py      # → "4 matches in 0 files:"   unusable
grep -n PATTERN dir/*.py             # → "5 matches in 0 files:"   unusable
grep -rn PATTERN path/to/file.py     # → renders (-r works on a single file)
grep -rn PATTERN dir/                # → renders
```

Fix: add `-r`, even when the target is one file. If the output is still wrong,
`rtk proxy grep ...` bypasses filtering entirely.

Do NOT respond to a collapsed result by rewriting the search in Python or another
language. That silently drops rtk and costs more tokens than the search it
replaced — the whole point of the proxy.

Refer to CLAUDE.md for full command reference.
