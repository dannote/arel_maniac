# frozen_string_literal: true

module ArelManiac
  module AnyOf
    extend ActiveSupport::Concern

    # Usage:
    #   Land.any_of(
    #     Land.where(land_category: "residential"),
    #     Land.where("area_sq_m > ?", 1000)
    #   )
    #
    #   Land.none_of(
    #     Land.where(land_category: "industrial"),
    #     Land.where(ownership_type: "state")
    #   )

    def any_of(*scopes)
      where(build_or_clause(scopes))
    end

    def none_of(*scopes)
      where.not(build_or_clause(scopes))
    end

    private

    def build_or_clause(scopes)
      nodes = scopes.map { |scope|
        relation = scope.is_a?(ActiveRecord::Relation) ? scope : where(scope)
        relation.arel.constraints.reduce { |combined, node| combined.and(node) }
      }
      nodes.reduce { |combined, node| combined.or(node) }
    end
  end
end
