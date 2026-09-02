# Agent notes — Never-lab profile

Canonical brief: [`CLAUDE.md`](./CLAUDE.md).

Questo repo è il **manifest Cursor/Claude** di Nicholas Antinori (Never-lab): skill stack, script di install, template MCP/hooks/CLI.

## Setup rapido

```bash
git clone https://github.com/Never-lab/Never-lab.git
cd Never-lab
./scripts/install-skills.sh
```

Poi in Cursor: plugin **claude-mem**, **superpowers**, **ponytail** dal marketplace.

## Contenuto

| Path | Cosa |
|------|------|
| `skills/manifest.json` | Catalogo skill con repo sorgente |
| `scripts/install-skills.sh` | Install globale in `~/.cursor/skills` |
| `skills/local/` | Custom: `analisi-engine`, `glowroot-contrib`, mirror `glowroot-ops` |
| `cursor/templates/` | Esempi `mcp.json`, `hooks.json`, `cli-config` |

## Glowroot (contrib)

Fork locale: `~/Documents/Glowroot` → `doc/AGENT.md` + rule `.cursor/rules/glowroot-local.mdc`.

Per coda PR / force-push maintainer: skill **`glowroot-contrib`**. Non usare snapshot PR vecchi nei session report.
