# frozen_string_literal: true

require_relative "lib/arel_maniac/version"

Gem::Specification.new do |spec|
  spec.name = "arel_maniac"
  spec.version = ArelManiac::VERSION
  spec.authors = ["Dan Poyarkov"]
  spec.email = ["dannote@gmail.com"]

  spec.summary = "The missing PostgreSQL features for ActiveRecord — no raw SQL allowed"
  spec.description = "DISTINCT ON, LATERAL joins, TABLESAMPLE, window functions, unions, " \
                     "JSONB builders, table partitioning, and custom Arel extensions for " \
                     "PostGIS and ParadeDB. One gem to replace them all."
  spec.homepage = "https://github.com/dannote/arel_maniac"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.1"
  spec.add_dependency "pg"
end
