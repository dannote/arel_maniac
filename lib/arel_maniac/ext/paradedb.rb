# frozen_string_literal: true

# Optional ParadeDB Arel extensions.
#
# Usage:
#   require "arel_maniac/ext/paradedb"
#
# Then on any Arel attribute:
#   Land.arel_table[:id].paradedb_score  # => paradedb.score("lands"."id")

module Arel
  module Attributes
    class Attribute
      def paradedb_score
        Arel::Nodes::NamedFunction.new("paradedb.score", [self])
      end unless method_defined?(:paradedb_score)
    end
  end
end
