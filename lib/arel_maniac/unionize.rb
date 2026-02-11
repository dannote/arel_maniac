# frozen_string_literal: true

module ArelManiac
  module Unionize
    extend ActiveSupport::Concern

    # Usage:
    #   Land.where(region: "77").union(Land.where(region: "50"))
    #   Land.where(region: "77").union_all(Land.where(region: "50"))
    #   Land.where(region: "77").union_except(Land.where(land_category: "industrial"))
    #   Land.where(region: "77").union_intersect(Land.where("area_sq_m > 1000"))

    def union(*scopes)
      apply_set_operation(:union, scopes)
    end

    def union_all(*scopes)
      apply_set_operation(:union_all, scopes)
    end

    def union_except(*scopes)
      apply_set_operation(:except, scopes)
    end

    def union_intersect(*scopes)
      apply_set_operation(:intersect, scopes)
    end

    def union_values
      @values[:union]
    end

    def union_values=(value)
      raise ImmutableRelation if @loaded

      @values[:union] = value
    end

    private

    def apply_set_operation(type, scopes)
      left = union_values || arel

      result = scopes.reduce(left) do |combined, scope|
        right = scope.is_a?(ActiveRecord::Relation) ? scope.arel : scope
        case type
        when :union then ::Arel::Nodes::Union.new(combined, right)
        when :union_all then ::Arel::Nodes::UnionAll.new(combined, right)
        when :except then ::Arel::Nodes::Except.new(combined, right)
        when :intersect then ::Arel::Nodes::Intersect.new(combined, right)
        end
      end

      relation = spawn
      relation.union_values = result
      relation
    end

    def build_arel(*)
      if union_values
        subquery = ::Arel::Nodes::As.new(union_values, ::Arel.sql(klass.table_name))
        ::Arel::SelectManager.new.from(subquery).project(::Arel.star)
      else
        super
      end
    end
  end
end
