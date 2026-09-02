---
name: analisi-engine
description: >
  Dispatch analysis of JVM/SQL performance dumps dropped into Analisi/inbox
  (or any path the user points to). Classifies Glowroot traces, thread dumps,
  GC logs, SQL deadlock XML, JVMDiag sessions, then runs the matching engine
  under Lavoro/Scripts/Python and writes to Analisi/out. Use when user says
  /analisi-engine, drops exports in inbox, asks to analyze a glowroot/thread
  dump/gc.log/deadlock, or compare before/after traces.
---

# /analisi-engine — dispatcher motori

Workspace tipico: `Lavoro/Analisi/`.
Motori: `Lavoro/Scripts/Python/<engine>/`.
Non reinventare soglie: usa i playbook sotto.

## Attivazione

1. User dice `/analisi-engine` **oppure** chiede di analizzare file in `inbox/` / path espliciti.
2. Elenca input nuovi in `inbox/` (e path passati).
3. **Classifica per contenuto** (tabella sotto), non solo per estensione.
4. Lancia il motore (comando esatto). Scrivi artefatti in `out/<cliente-o-data>/`.
5. Leggi output + playbook → diagnosi breve (criticità, cause, 3 azioni).
6. Se input misto → esegui più motori e unisci con priorità: **errore → deadlock JVM/SQL → SQL strutturale → HTTP esterno → CPU/GC**.

Storici in `reports/<cliente>/`: **non** rilanciare motori; sintetizza dal markdown già scritto.

---

## Classificazione (ordine: prima regola che matcha)

Sniffa i primi ~200KB (o `rg -l` sul file).

| # | Segnale (contenuto / layout) | Motore | Playbook |
|---|------------------------------|--------|----------|
| 1 | `<script … id="headerJson">` oppure JSON root con `header`+`entries`(+`sharedQueryTexts`) | **GlowrootTraceAnalyzer** | `GlowrootTraceAnalyzer/MOTORE_ANALISI.md` |
| 2 | Root XML `<deadlock>` + `process-list` / `resource-list` | **deadlock-visualizer** | README engine |
| 3 | Righe G1 tipo `:[GC ` + `secs]` / heap Eden–Survivors; nome spesso `*gc*.log` | **GCAnalyzer** | `GCAnalyzer/README.md` |
| 4 | Cartella sessione: `*thread*.txt` + (`*heap_info*` \| `*class_histogram*` \| `*nmt_*`) | **JVMDiagToolkit** (offline UI / batch se disponibile) | `JVMDiagToolkit/RUNBOOK.md` |
| 5 | `"…" #N` + `java.lang.Thread.State:` / `Full thread dump` / `Found … Java-level deadlock` | **ThreadDumpAnalyzer** | `ThreadDumpAnalyzer/README.md` |
| 6 | CSV con header `wait_type` + `wait_time_ms` (o alias) | **analisi_report wait-stats** | `analisi_report/findings.yaml` |
| 7 | CSV gauge/Glowroot (Date/Periodo o serie numeriche) **oppure** `*.yaml` recipe `charts:` | **CsvChart batch_analisi** | `CsvChart/batch_analisi.py` |
| 8 | Job YAML report (`tipo: perf_infra\|incident`, `findings:`) | **analisi_report compose** | `analisi_report/README.md` |
| 9 | Markdown già in `reports/` | Solo lettura + sintesi (+ riusa findings se chiedono bozza) | — |
| 10 | `.hprof`, JFR binario grezzo | **Non supportato** qui | MAT / jcmd a parte |

**Overlap thread dump:** dump isolato → ThreadDumpAnalyzer. Dump dentro sessione multi-artefatto → JVMDiagToolkit (vista health), ThreadDumpAnalyzer resta ok per deep-dive lock.

**Glowroot metrics CSV** (gauge/Date/Periodo, non trace HTML): → `batch_analisi` (preset `glowroot_line`). Trace HTML → GlowrootTraceAnalyzer. CSV latency correlazione GC → `GCAnalyzer/gc_bench_glowroot_correlation.py`.

---

## Comandi (CWD = root engine)

`PY=python3` (o venv dell’engine se c’è).  
`IN` = path assoluto file/cartella.  
`OUTDIR` = `Analisi/out/<stem>/` (crealo).

### GlowrootTraceAnalyzer

```bash
cd …/Scripts/Python/GlowrootTraceAnalyzer
$PY main.py "$IN" --report-out "$OUTDIR/report.txt" --issue-out "$OUTDIR/issue.md" --json-out "$OUTDIR/analysis.json"
# confronto prima/dopo:
$PY main.py "$IN_BEFORE" --compare "$IN_AFTER" --pr-out "$OUTDIR/confronto.md"
# batch:
$PY main.py --batch "$IN_GLOB" --json-out "$OUTDIR/batch.json"
```

Poi applica checklist `MOTORE_ANALISI.md` (durata, % sql/http/wait, antipattern, 3 azioni).

### ThreadDumpAnalyzer

```bash
cd …/Scripts/Python/ThreadDumpAnalyzer
$PY main.py "$IN" --top 15 --json-out "$OUTDIR/analysis.json" --report-out "$OUTDIR/report.txt"
# $IN può essere file o cartella di dump
```

### GCAnalyzer

```bash
cd …/Scripts/Python/GCAnalyzer
# Preferisci config YAML con settings.log_file_path = $IN
$PY GCanalyzer.py path/to/GCPath.yaml
# oppure CLI se documentata:
$PY cli.py path/to/GCPath.yaml
```

Se manca YAML: crea uno minimo in `OUTDIR/gc_path.yaml` che punta al log, output HTML in `OUTDIR/`.

### deadlock-visualizer (SQL Server)

```bash
cd …/Scripts/Python/deadlock-visualizer
$PY main.py "$IN" -o "$OUTDIR/deadlock.gif" --print-analysis --print-timeline
```

### JVMDiagToolkit

- Live (PID noto): `python jvm_diag_tool.py collect --pid …` (vedi RUNBOOK).
- Offline sessione: apri UI `python jvm_diag_ui.py` **oppure** se esiste API batch nei test, usala; altrimenti ThreadDumpAnalyzer sul `*thread*` + leggi heap/nmt a mano con regole RUNBOOK.

### CsvChart batch (grafici analisi)

```bash
cd …/Scripts/Python/CsvChart
.venv/bin/python batch_analisi.py "$IN_RECIPE.yaml"
# recipe: charts: [{csv, out, preset: glowroot_line|gauge_line|bar_rank, ...}]
```

### analisi_report (wait-stats + composer)

```bash
cd …/Scripts/Python/analisi_report
python3 main.py wait-stats "$IN.csv" -o "$OUTDIR/waits.md"
python3 main.py compose "$IN_JOB.yaml" -o "$OUTDIR/report.md"
python3 main.py list-findings
```

Composer: riusa paragrafi da `findings.yaml` (heap_gc_sawtooth, locking_severe, …) — **non** riscrivere a mano.

### Non usare per dump offline

- **perf** — UI SQL Server live  
- **benchmark** — stress host live  

---

## Output agente (sempre)

```
## Motore
- Input: …
- Classificato come: …
- Comando eseguito: …
- Artefatti: out/…

## Diagnosi
- Criticità:
- Cause (con numeri):
- Azioni (max 3, priority):

## Limiti
- Dati mancanti / engine non applicabile:
```

Non inventare query/stack assenti. Cita ms, %, conteggi, nomi span/tabella/thread.

---

## Inbox hygiene

Dopo run ok: sposta input processati in `inbox/done/YYYY-MM-DD/` (crea se manca). Lascia falliti in `inbox/` e spiega.
