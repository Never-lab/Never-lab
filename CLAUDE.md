# CLAUDE.md — Never-lab profile

Repo manifest per lo stack agent di Nicholas Antinori (Never-lab). Non è un'app — è configurazione, skill e script.

## Contesto

- **Lavoro:** Technical Operation healthcare, JVM/APM (Glowroot), SQL, performance analysis.
- **Stack repo:** Java, Python, TypeScript — vedi [GitHub Never-lab](https://github.com/Never-lab).

## Regole agent

- Chat: italiano. README pubblico: italiano, tono umano.
- Skill **`no-ai-slop`** prima di commit testi.
- Mai `Co-authored-by: Cursor`.
- No specs/plans MD di default.

## Skill installate (starter pack + plugin)

Vedi `skills/manifest.json`. Core:

- **Memoria:** claude-mem (`mem-search`, `learn-codebase`, `graphify`, …)
- **Workflow:** superpowers, ponytail, karpathy-guidelines
- **JVM:** analisi-engine, glowroot-ops, sql-optimizer, log-analyzer
- **Spring:** spring-boot-test-patterns, spring-boot-actuator
- **Frontend:** react-code-review, typescript-security-review, fallow
- **Docs:** xlsx, docx, mcp-builder
- **Security:** cybersecurity (invoke esplicito)

## Sync tra agenti

```bash
npm install -g sync-skill
npx sync-skill claude cursor
```
