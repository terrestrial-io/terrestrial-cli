require 'spec_helper'

describe Terrestrial::Cli::Bootstrapper do

  it "deduplicates strings" do
    entries = [
      {
        "string" => "mah string",
        "file" => "/path/to/file_1.storyboard",
        "language" => :ios_storyboard,
        "type" => "some type?",
        "line_number" => nil,
        "metadata" => {
          "storyboard_element_id" => "random-id"
        }
      },
      {
        "string" => "mah string",
        "language" => :swift,
        "file" => "/path/to/file_2.swift",
        "type" => "some other type",
        "line_number" => 12
      }
    ]

    result = Terrestrial::Cli::Bootstrapper::Result.new

    entries.each do |entry|
      result.add(entry)
    end

    expect(result.length).to eq 1

    deduplicated_entry = result[0]
    expect(deduplicated_entry.string).to eq "mah string"
    expect(deduplicated_entry.occurences.count).to eq 2

    expect(deduplicated_entry.occurences[0].file).to eq "/path/to/file_1.storyboard"
    expect(deduplicated_entry.occurences[0].type).to eq "some type?"
    expect(deduplicated_entry.occurences[0].language).to eq :ios_storyboard
    expect(deduplicated_entry.occurences[0].line_number).to eq nil
    expect(deduplicated_entry.occurences[0].metadata).to eq({ "storyboard_element_id" => "random-id" })

    expect(deduplicated_entry.occurences[1].file).to eq "/path/to/file_2.swift"
    expect(deduplicated_entry.occurences[1].type).to eq "some other type"
    expect(deduplicated_entry.occurences[1].language).to eq :swift
    expect(deduplicated_entry.occurences[1].line_number).to eq 12
    expect(deduplicated_entry.occurences[1].metadata).to eq({})
  end

  it "it can separate entries again when needed" do
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
      }
    ]

    result = Terrestrial::Cli::Bootstrapper::Result.new

    entries.each do |entry|
      result.add(entry)
    end

    expect(result.all_occurences.length).to eq 2
    expect(result.all_occurences[0].string).to eq "mah string"
    expect(result.all_occurences[0].identifier).to eq "MAH_STRING"

    expect(result.all_occurences[0].file).to eq "/path/to/file_1.storyboard"
    expect(result.all_occurences[0].type).to eq "some type?"
    expect(result.all_occurences[0].language).to eq :swift
    expect(result.all_occurences[0].line_number).to eq nil
    expect(result.all_occurences[0].metadata).to eq({ "storyboard_element_id" => "random-id" })

    expect(result.all_occurences[1].string).to eq "mah string"

    expect(result.all_occurences[1].file).to eq "/path/to/file_2.swift"
    expect(result.all_occurences[1].type).to eq "some other type"
    expect(result.all_occurences[1].language).to eq :swift
    expect(result.all_occurences[1].line_number).to eq 12
    expect(result.all_occurences[1].metadata).to eq({})
  end

  it "gives each occurence an index so that they can be later removed" do
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
        "string" => "mah other string",
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

    expect(result.all_occurences[0].result_index).to eq 0
    expect(result.all_occurences[1].result_index).to eq 1
    expect(result.all_occurences[2].result_index).to eq 2

    result.exclude_occurences([0])
    expect(result.all_occurences[0].result_index).to eq 1
    expect(result.all_occurences[1].result_index).to eq 2

    result.exclude_occurences([2])
    expect(result.all_occurences[0].result_index).to eq 1

    result.exclude_occurences([1])
    expect(result.all_occurences.count).to eq 0
  end

  it "generates an ID for a bootstrap entry from the string" do
    entry = Terrestrial::Cli::Bootstrapper::Entry.new("this is short")
    expect(entry.identifier).to eq "THIS_IS_SHORT"


    entry = Terrestrial::Cli::Bootstrapper::Entry.new("this is a string from which the ID will be generated")
    expect(entry.identifier).to eq "THIS_IS_A_STRING_FROM_WHICH_THE_ID_WILL_BE"

    # Gets rid of swift variables, other variables, and non-alphanumeric chars
    hash = {
        "string" => "this has &!1023 \\(variables) and %1$@ weird chars",
        "file" => "/path/to/file_1.storyboard",
        "language" => :swift,
        "type" => "some type?",
        "line_number" => nil,
        "metadata" => {
          "storyboard_element_id" => "random-id"
        }
      }
    entry = Terrestrial::Cli::Bootstrapper::Entry.from_hash(hash, 0)
    expect(entry.identifier).to eq "THIS_HAS_1023_AND_WEIRD_CHARS"
  end

  it "knows how to make swift variables in strings positional" do
    language = :swift
    string   = "This \\(has) two \\(variables)"
    entry = Terrestrial::Cli::Bootstrapper::Entry::Occurence.from_hash({
              "file" => "/file.swift", 
              "line_number" => 12, 
              "type" => "herp", 
              "language" => language, 
              "metadata" => {}, 
            }, 1)
    entry = Terrestrial::Cli::Bootstrapper::Entry::EntryOccurence.new(entry)
    entry.string = string

    expect(entry.formatted_string).to eq  "This %1$@ two %2$@"
  end

  it "knows how to format regular variables in swift too" do
    language = :swift
    string   = "This %@ two %@"
    entry = Terrestrial::Cli::Bootstrapper::Entry::Occurence.from_hash({
              "file" => "/file.swift", 
              "line_number" => 12, 
              "type" => "herp", 
              "language" => language, 
              "metadata" => {}, 
            }, 1)
    entry = Terrestrial::Cli::Bootstrapper::Entry::EntryOccurence.new(entry)
    entry.string = string

    expect(entry.formatted_string).to eq  "This %1$@ two %2$@"
  end

  it "knows how to make Objectice C style variables in strings positional" do
    language = :objc
    string   = "This %@ and %@"
    entry = Terrestrial::Cli::Bootstrapper::Entry::Occurence.from_hash({
              "file" => "/file.m", 
              "line_number" => 12, 
              "type" => "herp", 
              "language" => language, 
              "metadata" => {}, 
            }, 1)
    entry = Terrestrial::Cli::Bootstrapper::Entry::EntryOccurence.new(entry)
    entry.string = string

    expect(entry.formatted_string).to eq  "This %1$@ and %2$@"
  end
end
