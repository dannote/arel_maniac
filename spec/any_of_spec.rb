# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::AnyOf do
  before do
    Land.create!(region: "77", land_category: "residential", area_sq_m: 500)
    Land.create!(region: "50", land_category: "industrial", area_sq_m: 1000)
    Land.create!(region: "40", land_category: "agricultural", area_sq_m: 5000)
  end

  it "combines conditions with OR" do
    results = Land.any_of(
      Land.where(region: "77"),
      Land.where(land_category: "industrial")
    )
    expect(results.size).to eq(2)
  end

  it "negates combined conditions with none_of" do
    results = Land.none_of(
      Land.where(region: "77"),
      Land.where(land_category: "industrial")
    )
    expect(results.size).to eq(1)
    expect(results.first.region).to eq("40")
  end
end
