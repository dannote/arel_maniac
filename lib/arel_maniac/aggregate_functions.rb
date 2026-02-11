# frozen_string_literal: true

module ArelManiac
  module AggregateFunctions
    # Arel helpers for PostgreSQL aggregate functions not covered by ActiveRecord.
    #
    # Usage:
    #   ArelManiac.string_agg(Zone.arel_table[:name], ", ")
    #   ArelManiac.string_agg(Zone.arel_table[:name], ", ", order: Zone.arel_table[:name].asc)
    #   ArelManiac.array_agg(Land.arel_table[:id])
    #   ArelManiac.array_agg(Land.arel_table[:id], distinct: true)
    #   ArelManiac.generate_series(1, 10)
    #   ArelManiac.generate_series("2024-01-01", "2024-12-31", "1 month")

    def self.string_agg(expression, delimiter, order: nil)
      fn = Arel::Nodes::NamedFunction.new(
        "string_agg",
        [expression, Arel::Nodes.build_quoted(delimiter)]
      )
      order ? fn.order(order) : fn
    end

    def self.array_agg(expression, distinct: false, order: nil)
      expr = distinct ? Arel::Nodes::SqlLiteral.new("DISTINCT #{expression.to_sql}") : expression
      fn = Arel::Nodes::NamedFunction.new("array_agg", [expr])
      order ? fn.order(order) : fn
    end

    def self.generate_series(start_val, end_val, step = nil)
      args = [
        Arel::Nodes.build_quoted(start_val),
        Arel::Nodes.build_quoted(end_val)
      ]
      args << Arel::Nodes.build_quoted(step) if step

      Arel::Nodes::NamedFunction.new("generate_series", args)
    end

    def self.coalesce(*expressions)
      Arel::Nodes::NamedFunction.new("coalesce", expressions)
    end
  end
end
