# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::FastCount do
  it "returns an integer estimate" do
    expect(Land.fast_count).to be_a(Integer)
  end

  it "falls back to COUNT(*) when below threshold" do
    Land.create!(region: "77", area_sq_m: 100)
    count = Land.fast_count(999_999_999)
    expect(count).to eq(Land.count)
  end

  it "handles empty tables" do
    expect(Land.fast_count).to eq(0)
  end
end

RSpec.describe ArelManiac::EstimatedCount do
  before do
    5.times { |i| Land.create!(region: "77", area_sq_m: i * 100) }
  end

  it "returns an estimated count from EXPLAIN" do
    count = Land.where(region: "77").estimated_count
    expect(count).to be_a(Integer)
    expect(count).to be >= 0
  end
end
