#!/usr/bin/env bash
# Install Never-lab Cursor skill stack (global, Cursor agent).
set -euo pipefail

SKILLS="npx skills add -g --agent cursor --copy -y"
CURSOR_SKILLS="${HOME}/.cursor/skills"
AGENTS_SKILLS="${HOME}/.agents/skills"

mkdir -p "$CURSOR_SKILLS" "$AGENTS_SKILLS"

echo "==> Starter pack (npx skills)"
$SKILLS anthropics/skills --skill xlsx docx mcp-builder
$SKILLS TerminalSkills/skills --skill sql-optimizer log-analyzer keycloak
$SKILLS Kulaxyz/self-learning-skills --skill self-learning
$SKILLS fallow-rs/fallow-skills --skill fallow fallow-review
$SKILLS AgriciDaniel/claude-cybersecurity --skill cybersecurity

echo "==> developer-kit (manual copy)"
TMP=$(mktemp -d)
git clone --depth 1 https://github.com/giuseppe-trisciuoglio/developer-kit.git "$TMP"
for skill in spring-boot-test-patterns spring-boot-actuator; do
  src="$TMP/plugins/developer-kit-java/skills/$skill"
  cp -a "$src" "$CURSOR_SKILLS/$skill"
  cp -a "$src" "$AGENTS_SKILLS/$skill"
done
for skill in react-code-review typescript-security-review; do
  src="$TMP/plugins/developer-kit-typescript/skills/$skill"
  cp -a "$src" "$CURSOR_SKILLS/$skill"
  cp -a "$src" "$AGENTS_SKILLS/$skill"
done
rm -rf "$TMP"

echo "==> glowroot-ops (from Glowroot repo if present)"
GLOWROOT_OPS="${GLOWROOT_OPS:-$HOME/Scrivania/Lavoro/glowroot/skills/glowroot-ops}"
if [[ -d "$GLOWROOT_OPS" ]]; then
  cp -a "$GLOWROOT_OPS" "$CURSOR_SKILLS/glowroot-ops"
  cp -a "$GLOWROOT_OPS" "$AGENTS_SKILLS/glowroot-ops"
else
  echo "  skip: $GLOWROOT_OPS not found"
fi

echo "==> Local analisi-engine"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -d "$SCRIPT_DIR/../skills/local/analisi-engine" ]]; then
  cp -a "$SCRIPT_DIR/../skills/local/analisi-engine" "$CURSOR_SKILLS/"
  cp -a "$SCRIPT_DIR/../skills/local/analisi-engine" "$AGENTS_SKILLS/"
fi

echo "==> Plugin skills: install claude-mem, ponytail, superpowers via Cursor plugin marketplace"
echo "==> sync-skill CLI (optional): npm install -g sync-skill"

echo "Done. Skills in $CURSOR_SKILLS ($(ls "$CURSOR_SKILLS" | wc -l) dirs)"
