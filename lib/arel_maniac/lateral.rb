# frozen_string_literal: true

module ArelManiac
  module Lateral
    extend ActiveSupport::Concern

    # LATERAL join — the subquery can reference columns from preceding FROM items.
    #
    # Usage:
    #   Author.lateral_join(
    #     Book.where("books.author_id = authors.id").order(published_at: :desc).limit(3),
    #     as: "recent_books"
    #   )
    #   # => SELECT authors.* FROM authors
    #   #    JOIN LATERAL (SELECT ... WHERE books.author_id = authors.id ...) recent_books ON true
    #
    #   # With LEFT JOIN:
    #   Author.lateral_join(subquery, as: "recent_books", type: :left)
    def lateral_join(subquery, as:, type: :inner)
      spawn.lateral_join!(subquery, as: as, type: type)
    end

    def lateral_join!(subquery, as:, type: :inner)
      self.lateral_values += [{ subquery: subquery, as: as, type: type }]
      self
    end

    def lateral_values
      @values[:lateral] || []
    end

    def lateral_values=(values)
      raise ImmutableRelation if @loaded

      @values[:lateral] = values
    end

    private

    def build_arel(*)
      super.tap do |arel|
        lateral_values.each do |lateral|
          sub_arel = lateral[:subquery]
          sub_arel = sub_arel.arel if sub_arel.respond_to?(:arel)

          lateral_node = sub_arel.lateral(lateral[:as].to_s)

          join_klass = case lateral[:type]
          when :left then ::Arel::Nodes::OuterJoin
          else ::Arel::Nodes::InnerJoin
          end

          arel.join(lateral_node, join_klass).on(::Arel.sql("TRUE"))
        end
      end
    end
  end
end
