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

  context "format_foreign_translation" do

    it "writes a comment for translations that are placeholders" do
      entries = [
        double(:entry, string: "An string", identifier: "An identifier", placeholder?: false),
        double(:entry, string: "Placeholder string 1", identifier: "Placeholder identifier 1", placeholder?: true),
        double(:entry, string: "Another string", identifier: "Another identifier", placeholder?: false),
        double(:entry, string: "Placeholder string 2", identifier: "Placeholder identifier 2", placeholder?: true),
      ]

      writer = Terrestrial::Cli::DotStringsFormatter.new(entries)

      expected = <<-EXPECTED
"An identifier"="An string";

"Another identifier"="Another string";

// The following translations have been copied from the project base language because no translation was provided for them.
// iOS requires each Localizable.strings file to contain all keys used in the project. In order to provide proper fallbacks, Terrestrial includes missing translations in each translation resource file.

"Placeholder identifier 1"="Placeholder string 1";

"Placeholder identifier 2"="Placeholder string 2";
EXPECTED

      expect(writer.format_foreign_translation).to eq expected
    end
  end
end
