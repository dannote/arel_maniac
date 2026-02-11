# frozen_string_literal: true

module ArelManiac
  module EstimatedCount
    # Estimated row count for a scoped relation via EXPLAIN.
    #
    # Usage:
    #   Land.where(region: "77").estimated_count  # => 42000
    def estimated_count
      plan = connection.select_value("EXPLAIN #{to_sql}")
      plan.match(/rows=(\d+)/)[1].to_i
    end
  end
end
