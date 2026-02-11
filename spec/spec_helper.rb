# frozen_string_literal: true

require "active_record"
require "arel_maniac"

ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: "arel_maniac_test"
)

# Create test tables
ActiveRecord::Schema.define do
  self.verbose = false

  create_table :lands, force: true do |t|
    t.string :region
    t.string :land_category
    t.decimal :area_sq_m
    t.integer :cadastral_number_id
    t.timestamps
  end

  create_table :books, force: true do |t|
    t.integer :author_id
    t.string :title
    t.date :published_at
    t.timestamps
  end

  create_table :authors, force: true do |t|
    t.string :name
    t.timestamps
  end
end

class Land < ActiveRecord::Base; end
class Book < ActiveRecord::Base
  belongs_to :author
end
class Author < ActiveRecord::Base
  has_many :books
end

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end
