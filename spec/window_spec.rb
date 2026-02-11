# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::Window do
  before do
    Land.create!(region: "77", land_category: "residential", area_sq_m: 500)
    Land.create!(region: "77", land_category: "residential", area_sq_m: 300)
    Land.create!(region: "77", land_category: "industrial", area_sq_m: 1000)
  end

  it "generates WINDOW clause in SQL" do
    relation = Land
      .define_window(:w).partition_by(:land_category, order_by: { area_sq_m: :desc })
      .select_window(:row_number, over: :w, as: :rank)

    sql = relation.to_sql
    expect(sql).to match(/WINDOW "w" AS/i)
    expect(sql).to match(/PARTITION BY/i)
    expect(sql).to match(/row_number\(\) OVER w/i)
  end

  it "returns ranked results" do
    results = Land
      .define_window(:w).partition_by(:land_category, order_by: { area_sq_m: :desc })
      .select("lands.*")
      .select_window(:row_number, over: :w, as: :rank)

    top_per_category = results.select { |r| r[:rank] == 1 }
    expect(top_per_category.size).to eq(2)
  end

  it "supports multiple windows" do
    sql = Land
      .define_window(:w1).partition_by(:land_category)
      .define_window(:w2).partition_by(:region)
      .select("lands.*")
      .select_window(:row_number, over: :w1, as: :rank1)
      .select_window(:count, over: :w2, as: :cnt)
      .to_sql

    expect(sql).to match(/WINDOW "w1" AS/)
    expect(sql).to match(/"w2" AS/)
  end
end
