# frozen_string_literal: true

module ArelManiac
  module FastCount
    # Estimated row count from pg_class.reltuples.
    # Handles partitioned tables by summing child partitions.
    #
    # Usage:
    #   Land.fast_count        # => 4_100_000
    #   Land.fast_count(10_000) # falls back to COUNT(*) if estimate < threshold
    def fast_count(threshold = 0)
      result = connection.select_value(<<~SQL).to_i
        SELECT COALESCE(SUM(estimate), 0)::bigint FROM (
          SELECT (child.reltuples::float / GREATEST(child.relpages, 1)) *
                 (pg_relation_size(child.oid)::float / current_setting('block_size')::float)::integer AS estimate
          FROM pg_inherits
          INNER JOIN pg_class parent ON pg_inherits.inhparent = parent.oid
          INNER JOIN pg_class child ON pg_inherits.inhrelid = child.oid
          LEFT JOIN pg_namespace n ON n.oid = parent.relnamespace
          WHERE n.nspname = ANY(current_schemas(false))
            AND parent.relname = #{connection.quote(table_name)}
          UNION ALL
          SELECT (c.reltuples::float / GREATEST(c.relpages, 1)) *
                 (pg_relation_size(c.oid)::float / current_setting('block_size')::float)::integer AS estimate
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE n.nspname = ANY(current_schemas(false))
            AND c.relname = #{connection.quote(table_name)}
        ) t
      SQL

      result >= threshold ? result : count
    end
  end


end
