# frozen_string_literal: true

require "active_record"
require "arel_maniac/version"

module ArelManiac
  extend ActiveSupport::Autoload

  autoload :DistinctOn
  autoload :FastCount
  autoload :Lateral
  autoload :Tablesample
  autoload :Unionize
  autoload :AnyOf
  autoload :Window

  module Arel
    extend ActiveSupport::Autoload

    autoload :Nodes
    autoload :Visitors
  end
end

require "arel_maniac/arel/nodes"
require "arel_maniac/arel/visitors"

ActiveRecord::Relation.include ArelManiac::DistinctOn
ActiveRecord::Relation.include ArelManiac::Lateral
ActiveRecord::Relation.include ArelManiac::Tablesample
ActiveRecord::Relation.include ArelManiac::Unionize
ActiveRecord::Relation.include ArelManiac::AnyOf
ActiveRecord::Relation.include ArelManiac::Window
ActiveRecord::Base.extend ArelManiac::FastCount

ActiveRecord::Querying.delegate :distinct_on, :lateral_join, :tablesample,
  :union, :union_all, :union_except, :union_intersect,
  :define_window, :select_window,
  :any_of, :none_of, to: :all
