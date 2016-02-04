require 'spec_helper'

describe Terrestrial::Cli::Parser::AndroidXML do

  def example_file(name)
    "spec/fixtures/android/" + name
  end

  it "finds strings from resource files" do
    results = Terrestrial::Cli::Parser::AndroidXML.find_strings(example_file("strings.xml"))

    expect(results[0]["string"]).to eq "AndroidTest"
    expect(results[0]["identifier"]).to eq "app_name"
    expect(results[0]["type"]).to eq "android-strings-xml"
    expect(results[0]["file"]).to eq example_file("strings.xml")
    expect(results[0]["line_number"]).to be_nil

    expect(results[1]["string"]).to eq "Settings"
    expect(results[1]["identifier"]).to eq "action_settings"

    expect(results[2]["string"]).to eq "Hello, world! Lol"
    expect(results[2]["identifier"]).to eq "main_screen_text"
  end

  it "finds strings marked for Terrestrial and includes their IDs" do
    results = Terrestrial::Cli::Parser::AndroidXML.find_api_calls(example_file("terrestrial.xml"))

    expect(results.length).to eq 2

    expect(results[0]["string"]).to eq "AndroidTest"
    expect(results[0]["id"]).to eq "app_name"
    expect(results[0]["type"]).to eq "android-strings-xml"
    expect(results[0]["file"]).to eq example_file("terrestrial.xml")
    expect(results[0]["line_number"]).to be_nil

    expect(results[1]["string"]).to eq "Settings"
    expect(results[1]["id"]).to eq "action_settings"
    expect(results[1]["type"]).to eq "android-strings-xml"
    expect(results[1]["file"]).to eq example_file("terrestrial.xml")
    expect(results[1]["line_number"]).to be_nil
  end

  it "if the string element contains HTML, it will parse the HTML as a string" do
    results = Terrestrial::Cli::Parser::AndroidXML.find_strings(example_file("html_in_strings.xml"))

    expect(results[0]["string"]).to eq "<a href=\"https://www.google.pl/\">Google</a>"
    expect(results[0]["identifier"]).to eq "html_yo"
    expect(results[0]["type"]).to eq "android-strings-xml"
    expect(results[0]["file"]).to eq example_file("html_in_strings.xml")
    expect(results[0]["line_number"]).to be_nil
  end

  xit "notices if strings have variables" do
    results = Terrestrial::Cli::Parser::AndroidXML.find_strings(example_file("variables_in_strings.xml"))

    expect(results[0].string).to eq "You shot %1$d pounds of meat!"
    expect(results[0].identifier).to eq "meatShootingMessage"
    expect(results[0].type).to eq "android-strings-xml"
    expect(results[0].file).to eq example_file("variables_in_strings.xml")
    expect(results[0].variables).to eq ["%1$d"]
    expect(results[0].line_number).to be_nil
  end
end
