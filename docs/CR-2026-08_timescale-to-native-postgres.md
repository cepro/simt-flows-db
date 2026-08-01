# Change Request: migrate `flows` from TimescaleDB to native Postgres (Fly Managed Postgres)

| | |
|---|---|
| **Status** | PROPOSED — awaiting adoption into a roadmap round |
| **Author** | Orchestrator (simt-flows workspace), 2026-08-01 |
| **Target** | Fly Managed Postgres (MPG) cluster, PG17, London (`lhr`) |
| **Source** | TigerCloud `simt-prod` (`hwduz83g2a…tsdb.cloud.timescale.com:33025`), TimescaleDB 2.26.3 |
| **Scope** | The `flows` schema ONLY. `flux` and `myenergy` schemas are explicitly out of scope (flux is a heavy Timescale user — `counter_agg`, `interpolated_delta`, incremental cagg policies — and does NOT reduce the way flows does). |
| **Constraint** | MPG offers no `timescaledb`, no `timescaledb_toolkit`, no `pg_cron`, no `pg_partman`. No FDW/dblink is to be used (ruled out by Damon). The only permitted external component is a small, stateless scheduled process that "nudges" refreshes. |

## 0. Summary and evidence base

`flows` uses Timescale far more shallowly than its DDL suggests. Live-probed facts
(read-only, against `simt-prod`, 2026-08-01):

- All three continuous aggregates are **`materialized_only = true`** — no real-time
  merging of unmaterialised data. A plain `MATERIALIZED VIEW` is therefore an *exact*
  semantic replacement, not an approximation.
- The three flows caggs have **no refresh policy in production** (the four live
  `Refresh Continuous Aggregate Policy` jobs — 1013–1016 — all target `flux.mg_*`
  aggregates). `flows.circuit_interval_hh` was materialised to 2026-02-28 while its
  source ran to 2026-03-31: today's real-world behaviour is "manually refreshed,
  sometimes". Any scheduled refresh is an *improvement* on the status quo.
- Total size of the six hypertables: **2.06 GB**; the largest,
  `register_interval_hh`, is 1.47 GB / 10,439,831 rows. Trivial for stock PG17 btrees;
  full matview recomputes are seconds, so incremental materialisation is not needed.
- The only Timescale function used anywhere in the schema is `time_bucket` (six call
  sites, all inside the cagg definitions). No `time_bucket_gapfill`, `locf`,
  `interpolate`, `first()`, `last()`. `timescaledb_toolkit` is installed and never
  called. No compression, no retention, no chunk tuning (`create_hypertable` is always
  the bare 2-arg form → default 7-day chunks).

Every Timescale feature flows exercises maps to native PG17 + one stateless scheduled
`REFRESH`. Sections 1–6 give the feature-by-feature specification with code.

---

## 1. Extensions

**Today** (`sqitch/deploy/0000_initial.sql:2-3`):

```sql
CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE EXTENSION IF NOT EXISTS timescaledb_toolkit with schema "extensions";
```

**Change:** omit both lines on the MPG deploy. Nothing else in the schema references
either extension except the constructs rewritten in §2–§5. No replacement extension is
required from MPG's list (plpgsql suffices; `gen_random_uuid()` is core PG13+).

---

## 2. Hypertables → plain tables (6 tables)

**Today:** six `SELECT public.create_hypertable('flows.<t>', 'timestamp')` calls
(`0000_initial.sql:271, 332-336`) over `register_interval_hh`, `meter_csq`,
`meter_health_history`, `meter_voltage`, `meter_3p_voltage`, `meter_prepay_balance`.

**Change:** keep every `CREATE TABLE` byte-identical; delete the six
`create_hypertable` calls.

**⚠ Index replacement — the one non-obvious step.** `create_hypertable` auto-creates
an index on the time column (`("timestamp" DESC)`) on every hypertable. Two tables
also have explicit unique constraints that survive unchanged:

```sql
-- already present, unchanged:
ALTER TABLE flows.register_interval_hh
  ADD CONSTRAINT register_interval_hh_unique UNIQUE (register_id, "timestamp");
ALTER TABLE flows.meter_prepay_balance
  ADD CONSTRAINT meter_prepay_balance_unique UNIQUE (meter_id, "timestamp");
```

The other four tables have NO explicit index — they were relying entirely on
Timescale's auto index. Recreate equivalent (better: composite) indexes explicitly:

```sql
CREATE INDEX meter_csq_meter_ts_idx            ON flows.meter_csq            (meter_id, "timestamp" DESC);
CREATE INDEX meter_health_history_meter_ts_idx ON flows.meter_health_history (meter_id, "timestamp" DESC);
CREATE INDEX meter_voltage_meter_ts_idx        ON flows.meter_voltage        (meter_id, "timestamp" DESC);
CREATE INDEX meter_3p_voltage_meter_ts_idx     ON flows.meter_3p_voltage     (meter_id, "timestamp" DESC);
-- time-ordered scans across all registers (matview refresh, gap analyses):
CREATE INDEX register_interval_hh_ts_idx       ON flows.register_interval_hh ("timestamp");
```

**Outcome parity:** identical insert path (the five `meter_shadows` fan-out triggers —
`meter_csq_insert()`, `meter_voltage_insert()`, etc. — are plain PL/pgSQL and move
unchanged), identical query plans or better at current scale (10M rows), identical
uniqueness guarantees. Timescale's internal `ts_insert_blocker` triggers disappear
automatically — do not recreate.

**Future escape hatch (not day-one):** if `register_interval_hh` ever reaches hundreds
of millions of rows, convert to native `PARTITION BY RANGE ("timestamp")` with monthly
partitions created ahead-of-time by the scheduler (§5). Not justified at 10M rows.

---

## 3. Continuous aggregates → plain materialized views (3, chained)

**Today** (`0000_initial.sql:274-292, 340-346`): `circuit_interval_hh` (30-min bucket,
`circuit_register` validity-window join) → `circuit_interval_daily` → 
`circuit_interval_monthly`, all `WITH (timescaledb.continuous)`, all confirmed
`materialized_only = true` in production.

**Change:** same names, same columns, same SELECTs; `WITH (timescaledb.continuous)`
dropped; `time_bucket` swapped per §4; unique index added to each (required for
`REFRESH ... CONCURRENTLY`). Create `WITH NO DATA`, then populate via first refresh.

```sql
CREATE MATERIALIZED VIEW flows.circuit_interval_hh AS
SELECT cr.circuit AS circuit_id,
    date_bin('30 minutes'::interval, ri."timestamp",
             TIMESTAMPTZ '2000-01-01T00:00:00Z')       AS "timestamp",
    sum(ri.kwh) AS kwh
   FROM flows.circuit_register cr
   JOIN flows.register_interval_hh ri ON ri.register_id = cr.register
  WHERE ri."timestamp" >= cr.start_time
    AND (ri."timestamp" < cr.end_time OR cr.end_time IS NULL)
  GROUP BY cr.circuit, 2
WITH NO DATA;

CREATE UNIQUE INDEX circuit_interval_hh_uq
    ON flows.circuit_interval_hh (circuit_id, "timestamp");

CREATE MATERIALIZED VIEW flows.circuit_interval_daily AS
SELECT circuit_id,
    date_trunc('day', "timestamp", 'UTC') AS day,
    sum(kwh) AS kwh
   FROM flows.circuit_interval_hh
  GROUP BY circuit_id, 2
WITH NO DATA;

CREATE UNIQUE INDEX circuit_interval_daily_uq
    ON flows.circuit_interval_daily (circuit_id, day);

CREATE MATERIALIZED VIEW flows.circuit_interval_monthly AS
SELECT circuit_id,
    date_trunc('month', day, 'UTC') AS month,
    sum(kwh) AS kwh
   FROM flows.circuit_interval_daily
  GROUP BY circuit_id, 2
WITH NO DATA;

CREATE UNIQUE INDEX circuit_interval_monthly_uq
    ON flows.circuit_interval_monthly (circuit_id, month);
```

**Grants** (replicating `0000_initial.sql:1038-1046, 1080-1082`):

```sql
GRANT SELECT ON flows.circuit_interval_hh, flows.circuit_interval_daily,
                flows.circuit_interval_monthly TO grafanareader, tableau;
GRANT SELECT, INSERT, DELETE, UPDATE ON flows.circuit_interval_hh,
                flows.circuit_interval_daily, flows.circuit_interval_monthly TO flows;
```

**Semantics notes:**

- Column names preserved exactly (`"timestamp"` / `day` / `month`; `circuit_id`,
  `kwh`) — PostgREST/Grafana/Tableau consumers see an unchanged relation shape.
- `REFRESH ... CONCURRENTLY` keeps readers unblocked during refresh but cannot run on
  a never-populated matview: the **first** refresh after `WITH NO DATA` must be plain
  `REFRESH MATERIALIZED VIEW` (the migration script does this once, §6).
- Refresh MUST run in dependency order hh → daily → monthly (the scheduler function in
  §5 enforces this by construction — simpler and more correct than Timescale's
  staggered `initial_start` workaround for chained caggs).
- Full-recompute self-healing: any upstream correction (backfills, register→circuit
  re-mapping, `circuit_register` window edits) is fully absorbed at the next refresh.
  No invalidation bookkeeping exists to go wrong.

---

## 4. `time_bucket` → `date_bin` / `date_trunc`

All six call sites are inside the §3 view definitions; no application code calls
`time_bucket`. Equivalence used:

| Timescale | Native PG17 | Notes |
|---|---|---|
| `time_bucket('00:30:00'::interval, ts)` | `date_bin('30 minutes'::interval, ts, TIMESTAMPTZ '2000-01-01T00:00:00Z')` | `date_bin` is core PG14+. Both align 30-min buckets to :00/:30 (any midnight-anchored origin is equivalent because 30 min divides 24 h; Timescale's default origin 2000-01-03 is itself midnight-anchored). Byte-identical results. |
| `time_bucket('1 day'::interval, ts)` | `date_trunc('day', ts, 'UTC')` | Three-arg `date_trunc` (PG16+) pins the zone explicitly — do NOT use the two-arg form, which silently inherits the session `TimeZone`. `time_bucket` on `timestamptz` buckets in UTC; identical on our UTC-stored data (org time policy: store UTC). |
| `time_bucket('1 mon'::interval, ts)` | `date_trunc('month', ts, 'UTC')` | Same reasoning. Calendar-month boundaries identical in UTC. |

**Verification of equivalence** is part of migration acceptance (§6): monthly
`sum(kwh)` per circuit from the new matviews must equal the same query against the
source caggs after a final source refresh.

---

## 5. Timescale job scheduler → refresh function + external nudge

### 5.1 What is being replaced

Three `add_job` calls (`0000_initial.sql:1012-1016`,
`0005_flows_patch_from_myenemy.sql:245-254`), each `'1d'` with
`initial_start => date_trunc('day', now()) + interval '27 hours'` (03:00 UTC), calling
the wrapper functions `flows.refresh_register_interval_hh_missing()`,
`flows.refresh_register_export_missing()`, `flows.refresh_register_import_missing()` —
which simply `REFRESH MATERIALIZED VIEW` three *already-plain* matviews. Those three
matviews and their SELECTs move unchanged; only the scheduling moves out.

Plus the (currently absent) refresh scheduling for the §3 rollup matviews.

### 5.2 In-database part: one refresh function + a log table

Consolidate all refresh logic in the DB so the external component stays dumb:

```sql
CREATE TABLE flows.refresh_log (
    ran_at      timestamptz NOT NULL DEFAULT now(),
    kind        text        NOT NULL,          -- 'rollups' | 'missing-views'
    ok          boolean     NOT NULL,
    duration_ms integer,
    detail      text
);
GRANT SELECT ON flows.refresh_log TO grafanareader, tableau, public_backend;

CREATE OR REPLACE FUNCTION flows.refresh_rollups() RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE t0 timestamptz := clock_timestamp();
BEGIN
    -- dependency order is load-bearing: hh feeds daily feeds monthly
    REFRESH MATERIALIZED VIEW CONCURRENTLY flows.circuit_interval_hh;
    REFRESH MATERIALIZED VIEW CONCURRENTLY flows.circuit_interval_daily;
    REFRESH MATERIALIZED VIEW CONCURRENTLY flows.circuit_interval_monthly;
    INSERT INTO flows.refresh_log (kind, ok, duration_ms)
    VALUES ('rollups', true,
            (extract(epoch from clock_timestamp() - t0) * 1000)::int);
EXCEPTION WHEN OTHERS THEN
    INSERT INTO flows.refresh_log (kind, ok, detail) VALUES ('rollups', false, SQLERRM);
    RAISE;
END $$;

CREATE OR REPLACE FUNCTION flows.refresh_missing_views() RETURNS void
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE t0 timestamptz := clock_timestamp();
BEGIN
    REFRESH MATERIALIZED VIEW flows.register_interval_hh_missing;
    REFRESH MATERIALIZED VIEW flows.register_export_missing;
    REFRESH MATERIALIZED VIEW flows.register_import_missing;
    INSERT INTO flows.refresh_log (kind, ok, duration_ms)
    VALUES ('missing-views', true,
            (extract(epoch from clock_timestamp() - t0) * 1000)::int);
EXCEPTION WHEN OTHERS THEN
    INSERT INTO flows.refresh_log (kind, ok, detail) VALUES ('missing-views', false, SQLERRM);
    RAISE;
END $$;
```

Notes:
- `REFRESH MATERIALIZED VIEW` requires **ownership** of the matview. The functions are
  `SECURITY DEFINER` and must be created by the matview-owning role (the migration
  role), so the caller only needs `EXECUTE`. Grant execute to a dedicated minimal
  login role for the nudge:

```sql
CREATE ROLE flows_refresher LOGIN PASSWORD :'refresher_pw';
GRANT USAGE ON SCHEMA flows TO flows_refresher;
GRANT EXECUTE ON FUNCTION flows.refresh_rollups(), flows.refresh_missing_views()
    TO flows_refresher;
```

- The old per-view wrapper functions (`flows.refresh_register_*_missing(job_id,
  config)`) carry Timescale's job-callback signature; drop them on the new DB in
  favour of the two functions above.
- Verify early that MPG permits `CREATE ROLE` with `LOGIN` from the provisioning user
  (managed platforms sometimes restrict role DDL). If restricted, create
  `flows_refresher` via the MPG dashboard Users page instead and apply the grants.

### 5.3 External part: the stateless nudge

A Fly **scheduled Machine** — no daemon, no supercronic, no state. Fly's platform
scheduler boots the machine, the script runs two `psql` calls, the machine exits.
It cannot "crash and stay down" because nothing of ours stays up.

```dockerfile
# refresh-nudge/Dockerfile
FROM alpine:3.20
RUN apk add --no-cache postgresql17-client
COPY refresh.sh /refresh.sh
CMD ["/bin/sh", "/refresh.sh"]
```

```sh
# refresh-nudge/refresh.sh
set -eu
# DATABASE_URL is a Fly secret: postgres://flows_refresher:…@<mpg-host>/flows?sslmode=require
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "SELECT flows.refresh_rollups();"
# run the (cheaper-to-run-often) missing-views refresh on the same cadence;
# it was daily under Timescale only because that was the configured default
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "SELECT flows.refresh_missing_views();"
```

```sh
fly apps create flows-refresh-nudge --org microgridfoundry
fly secrets set -a flows-refresh-nudge DATABASE_URL='postgres://flows_refresher:…'
fly machine run . --app flows-refresh-nudge --schedule hourly --region lhr
```

**Failure-mode analysis (why this satisfies the "can't crash" requirement):** the
design is stateless (no watermarks/queues), idempotent (double-run harmless), and
self-healing (each refresh is a full recompute — a missed run means staleness, never
corruption or backlog; the next successful run catches up completely regardless of
how many runs were missed).

**Known limitation:** Fly's `--schedule` is coarse (`hourly|daily|weekly|monthly`,
phased off machine creation time — not cron expressions). Hourly rollup refresh
comfortably beats the production status quo (unscheduled, last refreshed a month
behind source). If a precise 03:00 run ever becomes a requirement, the fallback is a
supercronic container — accepted as out of scope for this CR.

**Staleness observability (closes the one residual risk):** freshness is queryable
in-band by anything already connected to the DB:

```sql
SELECT kind, max(ran_at) FILTER (WHERE ok) AS last_ok, max(ran_at) AS last_attempt
FROM flows.refresh_log GROUP BY kind;
```

Alert rule (Grafana or any existing probe surface): `last_ok(rollups)` older than
3 hours → warn. Note this is *more* observability than production has today, where the
caggs sat a month stale under Timescale unnoticed.

---

## 6. Data migration — same table data at the end

No FDW, no dblink. A one-off copier process (a `fly machine run` one-shot in `lhr`, or
a workstation) holds two connections and streams `COPY ... TO STDOUT` →
`COPY ... FROM STDIN` per table; data never touches disk. At 2.06 GB
datacenter-local, the full copy is minutes.

```python
# copy_table.py — psycopg2; SRC_DSN=TigerCloud simt-prod, DST_DSN=MPG
import io, psycopg2

def stream(src, dst, select_sql, target_table, cols):
    scur, dcur = src.cursor(), dst.cursor()
    buf = io.BytesIO()
    scur.copy_expert(f"COPY ({select_sql}) TO STDOUT (FORMAT binary)", buf)
    buf.seek(0)
    dcur.copy_expert(
        f"COPY {target_table} ({cols}) FROM STDIN (FORMAT binary)", buf)
    dst.commit()

# small tables: single shot. register_interval_hh (10.4M rows): month-sliced so an
# interruption resumes at the failed slice rather than restarting the world:
#   SELECT register_id, "timestamp", kwh FROM flows.register_interval_hh
#   WHERE "timestamp" >= %(m)s AND "timestamp" < %(m)s + interval '1 month'
```

**Copy set:** the six §2 tables plus every plain table in the schema (registry,
shadows, registers, circuits, `circuit_register`, properties/service-head trio,
escos, regions, `register_import`/`register_export`, …). Copy plain tables first
(FK targets), history tables second. **Disable nothing:** the fan-out triggers live on
`meter_shadows`, not on the history tables, so bulk `COPY` into history tables cannot
double-fire them; `meter_shadows` itself is copied with its triggers intact but COPY
of the shadows table does fire its triggers — so copy `meter_shadows` **with
`ALTER TABLE flows.meter_shadows DISABLE TRIGGER USER` during the copy**, re-enable
after (otherwise each copied shadow row appends spurious history rows).

**Not copied:** the three rollup matviews (recomputed on target — first refresh is the
non-`CONCURRENTLY` form, §3) and the three `*_missing` matviews (likewise).

**Sentinel preservation:** the 2026-05 outage backfill rows in
`meter_prepay_balance` are marked by `date_part('second', "timestamp") = 0 AND
date_part('microseconds', "timestamp") = 0` — plain data, preserved by COPY by
construction; the verification suite asserts their count explicitly.

**Verification suite** (run from the copier against both sides; all must match):

```sql
-- per table: row count, time bounds
SELECT count(*), min("timestamp"), max("timestamp") FROM flows.<t>;
-- register_interval_hh: monthly checksum
SELECT date_trunc('month', "timestamp", 'UTC') m, count(*), sum(kwh)
FROM flows.register_interval_hh GROUP BY 1 ORDER BY 1;
-- prepay: monthly checksum + sentinel count
SELECT date_trunc('month', "timestamp", 'UTC') m, count(*), sum(balance)
FROM flows.meter_prepay_balance GROUP BY 1 ORDER BY 1;
SELECT count(*) FROM flows.meter_prepay_balance
WHERE date_part('second', "timestamp") = 0
  AND date_part('microseconds', "timestamp") = 0;
-- rollup equivalence (after: source-side final cagg refresh; target-side first refresh)
SELECT circuit_id, date_trunc('month', "timestamp", 'UTC') m, sum(kwh)
FROM flows.circuit_interval_hh GROUP BY 1, 2 ORDER BY 1, 2;
```

---

## 7. Migration-file discipline (sqitch)

The MPG database is a **new lineage** — existing migrations `0000`–`0006` were
applied to TigerCloud and are immutable (rubric U-21); they are NOT edited. Proposal:
a parallel plan (e.g. `sqitch-pg/` with its own project URI and registry
`flows_sqitch_pg`) containing a single flattened `0000_initial_pg` — the current
schema (as per `sql/`/`dump/` plus `0001`–`0006`) with the §1–§5 changes applied.
Future migrations continue on that plan only. The TigerCloud plan is frozen at `0006`
once cutover completes.

## 8. Sequencing (indicative gates, for the roadmap discussion)

1. **G-A** — MPG cluster provisioned (PG17, `lhr`); role DDL capability verified
   (§5.2 note); `0000_initial_pg` deployed; smoke: PostgREST-compatible roles
   (`flows`, `public_backend`, `anon`, `grafanareader`, `tableau`,
   `flows_refresher`) exist and grants hold.
2. **G-B** — refresh machinery live: functions + log table + nudge machine; observe
   ≥ 24 h of green `refresh_log` on an empty/seeded DB.
3. **G-C** — data copy + verification suite green (source still authoritative; copy
   re-runnable).
4. **G-D** — consumer cutover (PostgREST `PGRST_DB_URI` repoint et al.) — separate,
   human-gated release ceremony; preview first per workspace discipline. Writers
   (mediator, scheduler) repoint in the same ceremony; their SQL is
   Timescale-agnostic (plain INSERTs) and needs no code change.
5. **Rollback at any gate:** the source DB is never written to or altered by this
   migration; rollback = don't repoint (G-A–C) or repoint back (G-D). Final source
   freeze + delta re-copy strategy for the cutover window to be specified in the G-D
   release doc.

## 9. Risks

| # | Risk | Mitigation |
|---|---|---|
| 1 | Silent refresh staleness (nudge quietly failing) | `refresh_log` age alert (§5.3); strictly better than status quo |
| 2 | Fly `--schedule` coarseness | Accepted; supercronic fallback documented |
| 3 | MPG restricts role DDL | Verified at G-A before anything else builds on it; dashboard Users page fallback |
| 4 | Full-recompute cost grows with data | At 10.4M rows: seconds. Revisit at ~100M rows (native partitioning + incremental rollup table are the documented escape hatches) |
| 5 | Write cutover misses in-flight rows | G-D freeze-window + delta re-copy (month-sliced copier is re-runnable by design) |
| 6 | `date_trunc` session-timezone footgun | Three-arg `'UTC'` form mandated throughout (§4); CI grep for two-arg `date_trunc` in the new plan |

## 10. Explicitly out of scope

- `flux` and `myenergy` schemas and anything on the shared TigerCloud instance beyond
  `flows`.
- Any change to writer applications (`simt-emlite` mediator, `simt-fly-scheduler`),
  PostgREST configuration, dashboards, or existing repos — cutover repointing is G-D's
  release ceremony, not this CR.
- Retention, compression, and partitioning — never configured under Timescale; noted
  only as future options the same nudge can execute.
