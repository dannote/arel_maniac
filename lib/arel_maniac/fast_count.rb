# frozen_string_literal: true

module ArelManiac
  module FastCount
    # Estimated row count from pg_class.reltuples.
    # Useful for tables with millions of rows where exact COUNT(*) is too slow.
    #
    # Usage:
    #   Land.fast_count        # => 4_100_000
    #   Land.fast_count(10_000) # falls back to COUNT(*) if estimate < threshold
    def fast_count(threshold = 0)
      result = connection.select_value(
        "SELECT reltuples::bigint FROM pg_class WHERE relname = #{connection.quote(table_name)}"
      ).to_i

      if result >= threshold
        result
      else
        count
      end
    end
  end
end
