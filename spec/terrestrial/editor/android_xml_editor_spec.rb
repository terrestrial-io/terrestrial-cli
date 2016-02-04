require 'spec_helper'

describe Terrestrial::Cli::Editor::AndroidXML do

  def duplicate_file_as(name)
    `rm -f '#{Dir.pwd}/spec/fixtures/android/#{name}'`
    `cp '#{Dir.pwd}/spec/fixtures/android/strings.xml' '#{Dir.pwd}/spec/fixtures/android/#{name}'`
  end

  it "adds attributes to the strings.xml file" do
    duplicate_file_as("foo_strings.xml")

    entry = double(:entry,
      string: "Hello, world! Lol",
      file: "spec/fixtures/android/foo_strings.xml",
      type: "android-strings-xml",
      identifier: "main_screen_text"
    )
    
    Terrestrial::Cli::Editor::AndroidXML.find_and_edit_line(entry)
    
    expect(
      File.read("spec/fixtures/android/foo_strings.xml")
    ).to eq '<resources>
  <string name="app_name">AndroidTest</string>
  <string name="action_settings">Settings</string>
  <string name="main_screen_text" terrestrial="true">Hello, world! Lol</string>
</resources>'

    `rm '#{Dir.pwd}/spec/fixtures/android/foo_strings.xml' || true`
  end
end
