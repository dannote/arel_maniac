# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::DistinctOn do
  before do
    Land.create!(region: "77", land_category: "residential", area_sq_m: 500)
    Land.create!(region: "77", land_category: "industrial", area_sq_m: 1000)
    Land.create!(region: "50", land_category: "residential", area_sq_m: 200)
  end

  it "selects distinct rows by column" do
    results = Land.distinct_on(:region).order(:region, area_sq_m: :desc)
    expect(results.map(&:region)).to contain_exactly("50", "77")
  end

  it "supports multiple columns" do
    results = Land.distinct_on(:region, :land_category).order(:region, :land_category, area_sq_m: :desc)
    expect(results.to_a.size).to eq(3)
  end

  it "generates valid SQL with DISTINCT ON" do
    sql = Land.distinct_on(:region).to_sql
    expect(sql).to match(/DISTINCT ON/i)
  end

  it "handles count with distinct_on" do
    expect(Land.distinct_on(:region).count).to eq(2)
  end

  it "handles count with multiple distinct_on columns" do
    expect(Land.distinct_on(:region, :land_category).count).to eq(3)
  end

  it "raises on count with explicit column" do
    expect { Land.distinct_on(:region).count(:id) }.to raise_error(ArgumentError)
  end
end
