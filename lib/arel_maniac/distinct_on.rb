# frozen_string_literal: true

module ArelManiac
  module DistinctOn
    extend ActiveSupport::Concern

    # Usage:
    #   Land.distinct_on(:cadastral_number_id)
    #   Land.distinct_on(:cadastral_number_id, :land_category)
    #   Land.distinct_on(cadastral_number: :region)
    def distinct_on(*fields)
      spawn.distinct_on!(*fields)
    end

    def distinct_on!(*fields)
      fields.flatten!
      self.distinct_on_values += fields
      self
    end

    def count(column_name = nil)
      if distinct_on_values.empty?
        super
      else
        raise ArgumentError, "Cannot specify column_name with distinct_on" if column_name && column_name != :all

        scope = spawn
        scope.distinct_on_values = FROZEN_EMPTY_ARRAY
        columns = resolve_distinct_on_columns.map { |col|
          col.respond_to?(:relation) ? %("#{col.relation.name}"."#{col.name}") : col.to_s
        }

        if columns.size == 1
          scope.count("distinct #{columns.first}")
        else
          unscoped.from("(#{scope.select("DISTINCT ON (#{columns.join(", ")}) 1").to_sql}) t").count
        end
      end
    end

    def distinct_on_values
      @values[:distinct_on] || FROZEN_EMPTY_ARRAY
    end

    def distinct_on_values=(values)
      raise ImmutableRelation if @loaded

      @values[:distinct_on] = values
    end

    private

    FROZEN_EMPTY_ARRAY = [].freeze
    private_constant :FROZEN_EMPTY_ARRAY

    def build_arel(*)
      super.tap do |arel|
        unless distinct_on_values.empty?
          arel.distinct_on(resolve_distinct_on_columns)
        end
      end
    end

    def resolve_distinct_on_columns
      arel_columns(distinct_on_values.map { |field| resolve_field(field) })
    end

    def resolve_field(field)
      case field
      when String then field
      when Hash
        assoc = field.keys.first
        assoc_klass = klass.reflect_on_association(assoc).klass
        assoc_klass.arel_table[field[assoc]]
      else
        if klass.attribute_alias?(field)
          klass.arel_table[klass.attribute_alias(field).to_sym]
        else
          klass.arel_table[field]
        end
      end
    end
  end
end
