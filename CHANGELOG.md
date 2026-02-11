# Changelog

## 0.1.0

- Initial release
- `distinct_on` — PostgreSQL `DISTINCT ON` via ActiveRecord
- `lateral_join` — `LATERAL` subquery joins
- `tablesample` — `TABLESAMPLE BERNOULLI/SYSTEM`
- `union` / `union_all` / `union_except` / `union_intersect` — set operations
- `any_of` / `none_of` — OR-combined conditions
- `define_window` / `select_window` — window functions
- `fast_count` — estimated count via `pg_class.reltuples`
