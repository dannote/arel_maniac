# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::Unionize do
  before do
    Land.create!(region: "77", land_category: "residential", area_sq_m: 500)
    Land.create!(region: "50", land_category: "industrial", area_sq_m: 1000)
    Land.create!(region: "40", land_category: "agricultural", area_sq_m: 5000)
  end

  it "generates UNION SQL" do
    relation = Land.where(region: "77").union(Land.where(region: "50"))
    sql = relation.to_sql
    expect(sql).to match(/UNION/i)
  end

  it "generates UNION ALL SQL" do
    relation = Land.where(region: "77").union_all(Land.where(region: "50"))
    sql = relation.to_sql
    expect(sql).to match(/UNION ALL/i)
  end

  it "generates EXCEPT SQL" do
    relation = Land.where(region: ["77", "50"]).union_except(Land.where(region: "50"))
    sql = relation.to_sql
    expect(sql).to match(/EXCEPT/i)
  end

  it "generates INTERSECT SQL" do
    relation = Land.where(region: ["77", "50"]).union_intersect(Land.where(land_category: "industrial"))
    sql = relation.to_sql
    expect(sql).to match(/INTERSECT/i)
  end

  it "executes UNION and returns results" do
    results = Land.where(region: "77").union(Land.where(region: "50")).to_a
    expect(results.map(&:region)).to contain_exactly("77", "50")
  end

  it "executes UNION ALL with duplicates" do
    results = Land.where(region: "77").union_all(Land.where(region: "77")).to_a
    expect(results.size).to eq(2)
  end

  it "executes EXCEPT and returns difference" do
    results = Land.all.union_except(Land.where(region: "50")).to_a
    expect(results.map(&:region)).to contain_exactly("77", "40")
  end
end
