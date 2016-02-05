require 'spec_helper'

describe Terrestrial::Cli::EntryCollectionDiffer do
  let(:a) {{
    "string" => "string A",
    "identifier" => "IDENTIFIER_A",
    "context" => "context A"
  }}
  let(:b) {{
    "string" => "string B",
    "identifier" => "IDENTIFIER_B",
    "context" => "context B"
  }}
  let(:c) {{
    "string" => "string C",
    "identifier" => "IDENTIFIER_C",
    "context" => "context C"
  }}

  it "shows the additions from one collection to another" do
    first = [a,b]
    second = [a,b,c]
    expect(Terrestrial::Cli::EntryCollectionDiffer.additions(first, second)).to eq [c]

    first = [a,b,c]
    second = [a,b]
    expect(Terrestrial::Cli::EntryCollectionDiffer.additions(first, second)).to eq []

    first = []
    second = [a,b,c]
    expect(Terrestrial::Cli::EntryCollectionDiffer.additions(first, second)).to eq [a,b,c]
  end

  it "shows the omissions from one collection to another" do
    first = [a,b]
    second = [a]
    expect(Terrestrial::Cli::EntryCollectionDiffer.omissions(first, second)).to eq [b]

    first = [a,b]
    second = [a,b,c]
    expect(Terrestrial::Cli::EntryCollectionDiffer.omissions(first, second)).to eq []

    first = [a,b,c]
    second = []
    expect(Terrestrial::Cli::EntryCollectionDiffer.omissions(first, second)).to eq [a,b,c]
  end
end
