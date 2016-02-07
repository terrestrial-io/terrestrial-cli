require 'spec_helper'

describe Terrestrial::Cli::AndroidXmlParser do
  def example_file(name)
    "spec/fixtures/android/" + name
  end

  it "reads an Android strings.xml file and finds all strings" do
    results = Terrestrial::Cli::AndroidXmlParser.parse_file(example_file("strings.xml"))

    expect(results.length).to eq 3

    first = results[0]
    expect(first["string"]).to eq "AndroidTest"
    expect(first["identifier"]).to eq "app_name"
    expect(first["type"]).to eq "strings.xml"
    expect(first["context"]).to eq nil
    expect(first["file"]).to eq "spec/fixtures/android/strings.xml"

    second = results[1]
    expect(second["string"]).to eq "Settings"
    expect(second["identifier"]).to eq "action_settings"
    expect(second["type"]).to eq "strings.xml"
    expect(second["context"]).to eq nil
    expect(second["file"]).to eq "spec/fixtures/android/strings.xml"

    third = results[2]
    expect(third["string"]).to eq "Hello, world! Lol"
    expect(third["identifier"]).to eq "main_screen_text"
    expect(third["type"]).to eq "strings.xml"
    expect(third["context"]).to eq nil
    expect(third["file"]).to eq "spec/fixtures/android/strings.xml"
  end

  it "does not read strings that are market with terrestrial='false'" do
    results = Terrestrial::Cli::AndroidXmlParser.parse_file(example_file("disabled_strings.xml"))

    expect(results.length).to eq 1

    first = results[0]
    expect(first["string"]).to eq "Settings"
    expect(first["identifier"]).to eq "action_settings"
    expect(first["type"]).to eq "strings.xml"
    expect(first["context"]).to eq nil
    expect(first["file"]).to eq "spec/fixtures/android/disabled_strings.xml"
  end
end
