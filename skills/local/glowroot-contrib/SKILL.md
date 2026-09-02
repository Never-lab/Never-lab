---
name: glowroot-contrib
description: >-
  Interpret Glowroot fork PR queue and maintainer (nowheresly) activity —
  force-pushes, rebases, partial landings on main, whether to close PRs.
  Use when checking open Never-lab PRs, confused by maintainer force-push,
  asking if a PR can be closed, or aligning after upstream rebase prep.
---

# Glowroot contrib (PR / maintainer)

Chat with Nicholas: **Italian**. Upstream comments: **English** + skill **`no-ai-slop`**.

## Always live — never trust stale tables

```bash
gh pr list -A Never-lab -s open --repo glowroot/glowroot
gh pr view <n> --json number,title,state,mergeable,maintainerCanModify,commits,updatedAt,url
gh api repos/glowroot/glowroot/issues/<n>/timeline --paginate
# force-push events: .event == "head_ref_force_pushed"
git fetch upstream main
git log upstream/main --oneline -15
```

Author vs committer on a tip commit:

```bash
git log -1 --format="author=%an <%ae>%ncommitter=%cn <%ce>" <sha>
```

## Maintainer force-push = prep (default)

`@nowheresly` (Sylvere Richard) often **rebases** `Never-lab:<branch>` when the PR has **Allow edits from maintainers** (`maintainerCanModify: true`).

Signals:

| Signal | Meaning |
|--------|---------|
| Timeline: `nowheresly` `head_ref_force_pushed` | He rewrote the fork tip |
| committer = Sylvere, author = Never-lab / Copilot / Cursor | His rebase; your authorship kept |
| UI: “Never-lab and others added N commits” | Same — not a hostile takeover |

**Do not** treat this as rejection or a reason to close the PR.

## When content already landed on main

He may push/cherry-pick docs onto `main` (committer Sylvere) **without** closing the PR. Then the open PR may only contain leftovers (e.g. huge HTML).

Before advising close:

1. Diff PR vs `main`: `gh pr diff <n> --name-only`
2. Confirm useful paths already on `upstream/main`
3. Ask Nicholas, or close only if he agrees leftovers are intentional scrap

## Do / don’t

- **Don’t** close feature PRs just because he force-pushed.
- **Don’t** fight his rebase with another rebase unless tip diverged badly or he asked for something specific.
- **Do** keep CI green; respond to his review comments; short “rebased / addressed” notes.
- **Do** use **`babysit`** to watch one PR; **`mem-search`** for prior session context.

## Related

- Fork ops brief: Glowroot `doc/AGENT.md`
- Ops/wiki analysis (separate): skill **`glowroot-ops`** (explicit invoke)
