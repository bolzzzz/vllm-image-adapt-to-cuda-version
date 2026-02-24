#!/usr/bin/env bash
set -euo pipefail

START_COMMAND="${START_COMMAND:-}"

if [[ -z "${START_COMMAND//[[:space:]]/}" ]]; then
  echo "START_COMMAND is empty, no process started."
  exit 0
fi

parse_groups() {
  python3 - "$1" <<'PY'
import sys
s = sys.argv[1]

groups = []
i = 0
n = len(s)

while i < n:
    while i < n and s[i].isspace():
        i += 1
    if i >= n:
        break

    if s[i] != '{':
        # Fallback: treat the whole string as one command when no outer braces are used.
        print(s.strip())
        sys.exit(0)

    i += 1
    buf = []
    depth = 1
    quote = None
    while i < n:
        ch = s[i]
        if quote:
            if ch == '\\' and i + 1 < n:
                buf.append(ch)
                i += 1
                buf.append(s[i])
            elif ch == quote:
                quote = None
                buf.append(ch)
            else:
                buf.append(ch)
        else:
            if ch in ("'", '"'):
                quote = ch
                buf.append(ch)
            elif ch == '{':
                depth += 1
                buf.append(ch)
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    break
                buf.append(ch)
            else:
                buf.append(ch)
        i += 1

    if depth != 0:
        print("ERROR: Unmatched braces in START_COMMAND", file=sys.stderr)
        sys.exit(2)

    cmd = ''.join(buf).strip()
    if cmd:
        print(cmd)

    i += 1

PY
}

mapfile -t COMMANDS < <(parse_groups "$START_COMMAND")

if [[ ${#COMMANDS[@]} -eq 0 ]]; then
  echo "No runnable command parsed from START_COMMAND, exiting."
  exit 0
fi

echo "Parsed ${#COMMANDS[@]} command group(s)."

declare -a PIDS=()
for idx in "${!COMMANDS[@]}"; do
  cmd="${COMMANDS[$idx]}"
  echo "Launching group $((idx + 1)): $cmd"
  bash -lc "$cmd" &
  PIDS+=("$!")
done

for pid in "${PIDS[@]}"; do
  wait "$pid"
done
