# frozen_string_literal: true

module ArelManiac
  module Window
    extend ActiveSupport::Concern

    # PostgreSQL window functions via Arel.
    #
    # Usage:
    #   Land.define_window(:w).partition_by(:land_category, order_by: { area_sq_m: :desc })
    #       .select_window(:row_number, over: :w, as: :rank)
    #
    #   # Generates:
    #   # SELECT lands.*, row_number() OVER (w) AS rank
    #   # FROM lands
    #   # WINDOW w AS (PARTITION BY land_category ORDER BY area_sq_m DESC)

    def define_window(name)
      DefineWindowChain.new(spawn, name)
    end

    def select_window(function, *args, over:, as: nil)
      spawn.select_window!(function, args.flatten.compact, over: over, as: as)
    end

    def select_window!(function, args, over:, as: nil)
      fn = ::Arel::Nodes::NamedFunction.new(
        function.to_s,
        args.map { |a| a.is_a?(Symbol) ? klass.arel_table[a] : a }
      )

      window_ref = ::Arel::Nodes::SqlLiteral.new(over.to_s)
      expr = fn.over(window_ref)
      expr = expr.as(as.to_s) if as

      _select!(expr)
      self
    end

    def window_values
      @values[:window] || []
    end

    def window_values=(values)
      raise ImmutableRelation if @loaded

      @values[:window] = values
    end

    private

    def build_arel(*)
      super.tap do |arel|
        window_values.each do |win|
          named = arel.window(win[:name].to_s)
          win[:partition_by]&.each { |col| named.partition(col) }
          win[:order_by]&.each { |expr| named.order(expr) }
        end
      end
    end

    class DefineWindowChain
      def initialize(scope, name)
        @scope = scope
        @name = name
      end

      def partition_by(*columns, order_by: nil)
        partition_exprs = columns.map do |col|
          col.is_a?(Symbol) ? @scope.klass.arel_table[col] : col
        end

        order_exprs = case order_by
        when Hash
          order_by.map do |col, dir|
            node = col.is_a?(Symbol) ? @scope.klass.arel_table[col] : col
            dir == :desc ? node.desc : node.asc
          end
        when nil then nil
        else [order_by]
        end

        @scope.window_values = (@scope.window_values || []) + [{
          name: @name,
          partition_by: partition_exprs,
          order_by: order_exprs
        }]

        @scope
      end
    end
  end
end
