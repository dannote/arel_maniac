# frozen_string_literal: true

# Optional PostGIS Arel extensions.
# Supplements rgeo-activerecord's SpatialExpressions with missing functions.
#
# Usage:
#   require "arel_maniac/ext/postgis"
#
# Then on any geometry column Arel node:
#   Land.geometry_node.st_dwithin(Arel.spatial(point), 0.001)
#   Land.geometry_node.st_tileenvelope(14, 9799, 5373)
#   Land.geometry_node.st_transform(4326)
#   Land.geometry_node.st_makeenvelope(-74, 40, -73, 41, 4326)

raise LoadError, "rgeo-activerecord is required for arel_maniac/ext/postgis" unless defined?(RGeo::ActiveRecord)

module RGeo
  module ActiveRecord
    module SpatialExpressions
      def st_dwithin(rhs, distance)
        args = [self, rhs, Arel::Nodes.build_quoted(distance.to_f)]
        SpatialNamedFunction.new("ST_DWithin", args, [true, true, false])
      end unless method_defined?(:st_dwithin)

      def st_makeenvelope(xmin, ymin, xmax, ymax, srid = nil)
        args = [
          Arel::Nodes.build_quoted(xmin.to_f),
          Arel::Nodes.build_quoted(ymin.to_f),
          Arel::Nodes.build_quoted(xmax.to_f),
          Arel::Nodes.build_quoted(ymax.to_f)
        ]
        flags = [false, false, false, false]

        if srid
          args << Arel::Nodes.build_quoted(srid.to_i)
          flags << false
        end

        SpatialNamedFunction.new("ST_MakeEnvelope", args, flags)
      end unless method_defined?(:st_makeenvelope)

      def st_tileenvelope(zoom, tile_x, tile_y, bounds = nil, margin = nil)
        args = [
          Arel::Nodes.build_quoted(zoom.to_i),
          Arel::Nodes.build_quoted(tile_x.to_i),
          Arel::Nodes.build_quoted(tile_y.to_i)
        ]
        flags = [false, false, false]

        if bounds
          args << bounds
          flags << true
        end

        if margin
          args << Arel::Nodes.build_quoted(margin.to_f)
          flags << false
        end

        SpatialNamedFunction.new("ST_TileEnvelope", args, flags)
      end unless method_defined?(:st_tileenvelope)

      def st_transform(*args)
        fn_args = [self]
        flags = [true]

        case args.size
        when 1
          target = args.first
          literal = Arel::Nodes.build_quoted(target.is_a?(Integer) ? target : target.to_s)
          fn_args << literal
          flags << false
        when 2
          from, to = args
          fn_args << Arel::Nodes.build_quoted(from.to_s)
          flags << false
          fn_args << Arel::Nodes.build_quoted(to.is_a?(Integer) ? to : to.to_s)
          flags << false
        else
          raise ArgumentError, "st_transform: expected 1 or 2 arguments, got #{args.size}"
        end

        SpatialNamedFunction.new("ST_Transform", fn_args, flags)
      end unless method_defined?(:st_transform)
    end
  end
end
