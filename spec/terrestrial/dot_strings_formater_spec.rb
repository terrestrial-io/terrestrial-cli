require 'spec_helper'

describe Terrestrial::Cli::DotStringsFormatter do

  it "turns a hash of string entries into valid Localizable.strings format" do
    entries = [
      {
        "string" => "mah string",
        "file" => "/path/to/file_1.storyboard",
        "language" => :swift,
        "type" => "some type?",
        "line_number" => nil,
        "metadata" => {
          "storyboard_element_id" => "random-id"
        }
      },
      {
        "string" => "mah string",
        "file" => "/path/to/file_2.swift",
        "language" => :swift,
        "type" => "some other type",
        "line_number" => 12
      },
      {
        "string" => "mah string with a \\(variable)",
        "file" => "/path/to/file_4.swift",
        "language" => :swift,
        "type" => "some third type",
        "line_number" => 52
      }
    ]
    result = Terrestrial::Cli::Bootstrapper::Result.new

    entries.each do |entry|
      result.add(entry)
    end

    writer = Terrestrial::Cli::DotStringsFormatter.new(result.entries)
   

    expected = <<-EXPECTED
// Files:
// - /path/to/file_1.storyboard
// - /path/to/file_2.swift
"MAH_STRING"="mah string";

// Files:
// - /path/to/file_4.swift
"MAH_STRING_WITH_A"="mah string with a %1$@";
EXPECTED

    expect(writer.format).to eq expected
  end
end
