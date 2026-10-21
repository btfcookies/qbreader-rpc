#!/usr/bin/env bash
# Syncs websites/Q/QBReader into a local clone of PreMiD/Activities.
#   ./dev.sh check   lint + type check + build (what PreMiD's CI runs)
#   ./dev.sh dev     check, then start the live-reload dev server
# Set PREMID_DIR to reuse an existing clone; defaults to ./.premid
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
clone="${PREMID_DIR:-$here/.premid}"
target="$clone/websites/Q/QBReader"
mode="${1:-check}"

if [[ "$mode" != "check" && "$mode" != "dev" ]]; then
  echo "usage: $0 [check|dev]" >&2
  exit 2
fi

if [[ ! -d "$clone/.git" ]]; then
  git clone --depth 1 https://github.com/PreMiD/Activities.git "$clone"
fi
if [[ ! -d "$clone/node_modules" ]]; then
  (cd "$clone" && npm run prepare)
fi

mkdir -p "$target"
cp "$here/websites/Q/QBReader/presence.ts" "$here/websites/Q/QBReader/metadata.json" "$target/"

cd "$clone"
# antfu's eslint config silently drops rules when it detects an editor; CI does not.
env -u VSCODE_PID -u VSCODE_CWD -u VSCODE_IPC_HOOK_CLI -u TERM_PROGRAM \
  npx eslint websites/Q/QBReader --no-cache
npx pmd build QBReader

if [[ "$mode" == "dev" ]]; then
  npx pmd dev QBReader
fi
