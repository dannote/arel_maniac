# Changelog

## 0.1.0

- Initial release
- `distinct_on` — PostgreSQL `DISTINCT ON` with proper `count` support
- `lateral_join` — `LATERAL` subquery joins (inner and left)
- `tablesample` — `TABLESAMPLE BERNOULLI/SYSTEM` with optional seed
- `union` / `union_all` / `union_except` / `union_intersect` — set operations
- `any_of` / `none_of` — OR-combined conditions
- `define_window` / `select_window` — window functions
- `fast_count` — estimated count via `pg_class.reltuples` (handles partitioned tables)
- `estimated_count` — EXPLAIN-based row estimate for scoped relations
- `ArelManiac.string_agg` / `array_agg` / `generate_series` / `coalesce` — aggregate function helpers
- Optional `ext/postgis` — `st_dwithin`, `st_makeenvelope`, `st_tileenvelope`, `st_transform`
- Optional `ext/paradedb` — `paradedb_score` for BM25 ranking
