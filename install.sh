#!/usr/bin/env bash
# Chronary skill installer (macOS / Linux / WSL).
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Chronary/chronary-skills/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/Chronary/chronary-skills/main/install.sh | bash -s -- claude-code
#
# Targets:
#   claude-code | claude | cursor | windsurf | vscode | codex | all (default)

set -euo pipefail

TARGET="${1:-all}"
REPO_URL="https://github.com/Chronary/chronary-skills.git"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

echo "Cloning chronary-skills..."
git clone --depth 1 "$REPO_URL" "$TMPDIR/chronary-skills" >/dev/null 2>&1

SRC="$TMPDIR/chronary-skills"

install_claude_code() {
  local dest="$HOME/.claude/skills"
  mkdir -p "$dest"
  cp -R "$SRC/skills/." "$dest/"
  echo "Installed to $dest (Claude Code user skills)"
}

install_cursor() {
  local dest="$HOME/.cursor/skills"
  mkdir -p "$dest"
  cp -R "$SRC/skills/." "$dest/"
  echo "Installed to $dest (Cursor user skills)"
}

install_windsurf() {
  local dest="$HOME/.windsurf/skills"
  mkdir -p "$dest"
  cp -R "$SRC/skills/." "$dest/"
  echo "Installed to $dest (Windsurf user skills)"
}

install_vscode() {
  local dest="${PWD}/.github/skills"
  mkdir -p "$dest"
  cp -R "$SRC/skills/." "$dest/"
  echo "Installed to $dest (VS Code Copilot project skills)"
  echo "  Tip: commit this directory so your team picks up the skills."
}

install_codex() {
  local dest="$HOME/.codex/skills"
  mkdir -p "$dest"
  cp -R "$SRC/skills/." "$dest/"
  cp "$SRC/AGENTS.md" "$HOME/.codex/AGENTS.md" 2>/dev/null || true
  echo "Installed to $dest (Codex user skills)"
}

case "$TARGET" in
  claude-code|claude) install_claude_code ;;
  cursor)             install_cursor ;;
  windsurf)           install_windsurf ;;
  vscode|copilot)     install_vscode ;;
  codex)              install_codex ;;
  all)
    install_claude_code
    install_cursor
    install_windsurf
    install_codex
    ;;
  *)
    echo "Unknown target: $TARGET"
    echo "Targets: claude-code | cursor | windsurf | vscode | codex | all"
    exit 1
    ;;
esac

echo
echo "Next step: set CHRONARY_API_KEY and run 'npx -y @chronary/mcp' in your IDE config."
