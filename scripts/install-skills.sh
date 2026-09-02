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
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOWROOT_OPS_CANDIDATES=(
  "${GLOWROOT_OPS:-}"
  "$HOME/Documents/Glowroot/skills/glowroot-ops"
  "$HOME/Scrivania/Lavoro/glowroot/skills/glowroot-ops"
  "/data/progetti/Glowroot/skills/glowroot-ops"
  "$SCRIPT_DIR/../skills/local/glowroot-ops"
)
GLOWROOT_OPS=""
for c in "${GLOWROOT_OPS_CANDIDATES[@]}"; do
  [[ -n "$c" && -d "$c" ]] && GLOWROOT_OPS="$c" && break
done
if [[ -n "$GLOWROOT_OPS" ]]; then
  cp -a "$GLOWROOT_OPS" "$CURSOR_SKILLS/glowroot-ops"
  cp -a "$GLOWROOT_OPS" "$AGENTS_SKILLS/glowroot-ops"
  echo "  from $GLOWROOT_OPS"
else
  echo "  skip: glowroot-ops not found"
fi

echo "==> Local analisi-engine + glowroot-contrib"
for skill in analisi-engine glowroot-contrib; do
  if [[ -d "$SCRIPT_DIR/../skills/local/$skill" ]]; then
    cp -a "$SCRIPT_DIR/../skills/local/$skill" "$CURSOR_SKILLS/"
    cp -a "$SCRIPT_DIR/../skills/local/$skill" "$AGENTS_SKILLS/"
  fi
done

echo "==> Plugin skills: install claude-mem, ponytail, superpowers via Cursor plugin marketplace"
echo "==> sync-skill CLI (optional): npm install -g sync-skill"

echo "Done. Skills in $CURSOR_SKILLS ($(ls "$CURSOR_SKILLS" | wc -l) dirs)"
