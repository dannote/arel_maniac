# ArelManiac

The missing PostgreSQL features for ActiveRecord — no raw SQL allowed.

One gem to replace `activerecord-cte`, `active_record_distinct_on`, `fast_count`, and half of `activerecord_extended`.

## Installation

```ruby
gem "arel_maniac"
```

## Features

### DISTINCT ON

```ruby
Land.distinct_on(:cadastral_number_id)
Land.distinct_on(:cadastral_number_id, :land_category)

# With associations
Land.distinct_on(cadastral_number: :region)
```

### LATERAL Joins

```ruby
# Inner join
Author.lateral_join(
  Book.where("books.author_id = authors.id").order(published_at: :desc).limit(3),
  as: "recent_books"
)

# Left join
Author.lateral_join(subquery, as: "recent_books", type: :left)
```

### TABLESAMPLE

```ruby
# Bernoulli sampling (row-level, default)
Land.tablesample(5)

# System sampling (block-level, faster)
Land.tablesample(10, method: :system)

# Repeatable results
Land.tablesample(1, seed: 42)
```

### Set Operations

```ruby
Land.where(region: "77").union(Land.where(region: "50"))
Land.where(region: "77").union_all(Land.where(region: "50"))
Land.where(region: "77").union_except(Land.where(land_category: "industrial"))
Land.where(region: "77").union_intersect(Land.where("area_sq_m > 1000"))
```

### OR Conditions

```ruby
Land.any_of(
  Land.where(land_category: "residential"),
  Land.where("area_sq_m > ?", 1000)
)

Land.none_of(
  Land.where(land_category: "industrial"),
  Land.where(ownership_type: "state")
)
```

### Window Functions

```ruby
Land
  .define_window(:w).partition_by(:land_category, order_by: { area_sq_m: :desc })
  .select_window(:row_number, over: :w, as: :rank)
```

### Fast Count

```ruby
Land.fast_count              # estimated count from pg_class
Land.fast_count(10_000)      # fallback to COUNT(*) if estimate < threshold
```

## Rails Compatibility

- Rails 7.1+
- Ruby 3.2+
- PostgreSQL 14+

## Acknowledgments

Incorporates ideas and code from:
- [active_record_distinct_on](https://github.com/aha-app/active_record_distinct_on) (MIT)
- [ActiveRecordExtended](https://github.com/GeorgeKaraszi/ActiveRecordExtended) (MIT)
- [fast_count](https://github.com/fatkodima/fast_count) (MIT)

## License

MIT
