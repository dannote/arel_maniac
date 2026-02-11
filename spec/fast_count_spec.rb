# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::FastCount do
  it "returns an integer estimate" do
    expect(Land.fast_count).to be_a(Integer)
  end

  it "falls back to COUNT(*) when below threshold" do
    Land.create!(region: "77", area_sq_m: 100)
    # reltuples might be 0 for just-created tables until ANALYZE
    count = Land.fast_count(999_999_999)
    expect(count).to eq(Land.count)
  end
end
