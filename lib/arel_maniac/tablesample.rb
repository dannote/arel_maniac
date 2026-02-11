# frozen_string_literal: true

module ArelManiac
  module Tablesample
    extend ActiveSupport::Concern

    # PostgreSQL TABLESAMPLE — fast approximate sampling without scanning the whole table.
    #
    # Usage:
    #   Land.tablesample(5)                      # BERNOULLI 5%
    #   Land.tablesample(10, method: :system)     # SYSTEM 10% (faster, block-level)
    #   Land.tablesample(1, seed: 42)             # REPEATABLE(42)
    def tablesample(percentage, method: :bernoulli, seed: nil)
      spawn.tablesample!(percentage, method: method, seed: seed)
    end

    def tablesample!(percentage, method: :bernoulli, seed: nil)
      self.tablesample_value = { percentage: percentage, method: method, seed: seed }
      self
    end

    def tablesample_value
      @values[:tablesample]
    end

    def tablesample_value=(value)
      raise ImmutableRelation if @loaded

      @values[:tablesample] = value
    end

    private

    def build_arel(*)
      super.tap do |arel|
        next unless tablesample_value

        sample = tablesample_value
        method_name = sample[:method].to_s.upcase
        clause = "TABLESAMPLE #{method_name}(#{sample[:percentage].to_f})"
        clause += " REPEATABLE(#{sample[:seed].to_i})" if sample[:seed]

        # Replace the FROM source with a tablesample'd version
        table_ref = arel.source.left
        arel.from(::Arel.sql("#{table_ref.respond_to?(:name) ? table_ref.name : table_ref} #{clause}"))
      end
    end
  end
end
