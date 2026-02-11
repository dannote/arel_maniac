# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::Tablesample do
  before do
    100.times { |i| Land.create!(region: "77", area_sq_m: i * 10) }
  end

  it "samples with bernoulli (default)" do
    sql = Land.tablesample(50).to_sql
    expect(sql).to match(/TABLESAMPLE BERNOULLI\(50\.0\)/i)
  end

  it "samples with system method" do
    sql = Land.tablesample(10, method: :system).to_sql
    expect(sql).to match(/TABLESAMPLE SYSTEM\(10\.0\)/i)
  end

  it "supports repeatable seed" do
    sql = Land.tablesample(5, seed: 42).to_sql
    expect(sql).to match(/REPEATABLE\(42\)/i)
  end

  it "returns a subset of rows" do
    # 100% sample should return all rows
    expect(Land.tablesample(100).count).to eq(100)
  end
end
