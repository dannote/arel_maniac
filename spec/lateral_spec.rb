# frozen_string_literal: true

require "spec_helper"

RSpec.describe ArelManiac::Lateral do
  before do
    author = Author.create!(name: "Alice")
    Book.create!(author: author, title: "Book A", published_at: "2024-01-01")
    Book.create!(author: author, title: "Book B", published_at: "2025-01-01")
    Book.create!(author: author, title: "Book C", published_at: "2023-01-01")
    Author.create!(name: "Bob")
  end

  it "performs LATERAL inner join" do
    subquery = Book.select("books.*")
                   .where("books.author_id = authors.id")
                   .order(published_at: :desc)
                   .limit(2)

    results = Author.lateral_join(subquery, as: "recent_books")
                    .select("authors.name", "recent_books.title")

    expect(results.size).to eq(2)
    expect(results.map(&:name).uniq).to eq(["Alice"])
  end

  it "performs LATERAL left join" do
    subquery = Book.select("books.*")
                   .where("books.author_id = authors.id")
                   .limit(1)

    results = Author.lateral_join(subquery, as: "top_book", type: :left)
                    .select("authors.name", "top_book.title")

    expect(results.size).to eq(2)
    names = results.map(&:name)
    expect(names).to contain_exactly("Alice", "Bob")
  end

  it "generates SQL with LATERAL keyword" do
    subquery = Book.where("books.author_id = authors.id").limit(1)
    sql = Author.lateral_join(subquery, as: "recent").to_sql
    expect(sql).to match(/LATERAL/i)
    expect(sql).to match(/ON TRUE/i)
  end

  it "allows selecting columns from lateral subquery" do
    subquery = Book.select("books.title", "books.published_at")
                   .where("books.author_id = authors.id")
                   .order(published_at: :desc)
                   .limit(1)

    results = Author.lateral_join(subquery, as: "latest")
                    .select("authors.name", "latest.title", "latest.published_at")

    expect(results.first.name).to eq("Alice")
    expect(results.first[:title]).to eq("Book B")
  end
end
