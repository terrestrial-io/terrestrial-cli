require 'spec_helper'

describe Terrestrial::Cli::Parser::IosStrings do

  it "parses an Localizable.strings file format for strings and identifiers" do
    file = "spec/fixtures/ExampleLocalizable.strings"

    results = Terrestrial::Cli::Parser::IosStrings.find_api_calls(file)

    expect(results.count).to eq 4

    first = results[0]
    expect(first[:string]).to eq "nom d'utilisateur"
    expect(first[:id]).to eq "Username"
    expect(first[:type]).to eq "localizable.strings"
    expect(first[:context]).to eq "No comment provided by engineer."
    expect(first[:file]).to eq "spec/fixtures/ExampleLocalizable.strings"

    second = results[1]
    expect(second[:string]).to eq "profil de %1$@"
    expect(second[:id]).to eq "Main_Profile"
    expect(second[:type]).to eq "localizable.strings"
    expect(second[:context]).to eq nil
    expect(second[:file]).to eq "spec/fixtures/ExampleLocalizable.strings"

    third = results[2]
    expect(third[:string]).to eq "Hello %@,\n\nCheck out %@.\n\nSincerely,\n\n%@"
    expect(third[:id]).to eq "multiline"
    expect(third[:type]).to eq "localizable.strings"
    expect(third[:context]).to eq nil
    expect(third[:file]).to eq "spec/fixtures/ExampleLocalizable.strings"

    fourth = results[3]
    expect(fourth[:string]).to eq "Hello %@,\nyou"
    expect(fourth[:id]).to eq "multiline_comment"
    expect(fourth[:type]).to eq "localizable.strings"
    expect(fourth[:context]).to eq "this is a\n multiline\n comment"
    expect(fourth[:file]).to eq "spec/fixtures/ExampleLocalizable.strings"
  end

  it "can handle UTF-16 encoded files" do
    # genstrings encodes all strings in UTF-16
    file = "spec/fixtures/UTF_16_Localizable.strings"

    results = Terrestrial::Cli::Parser::IosStrings.find_api_calls(file)
    expect(results.count).to eq 1


    first = results[0]
    expect(first[:string]).to eq "Choose Audio Track"
    expect(first[:id]).to eq "CHOOSE_AUDIO_TRACK"
    expect(first[:type]).to eq "localizable.strings"
    expect(first[:context]).to eq nil
    expect(first[:file]).to eq "spec/fixtures/UTF_16_Localizable.strings"
  end
end
