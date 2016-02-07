require 'spec_helper'

describe Terrestrial::Cli::AndroidXmlFormatter do

  it "generates valid XML with the strings" do
    entries = [
      double(:entry, identifier: "foo", string: "bar"),
      double(:entry, identifier: "chuck", string: "norris"),
      double(:entry, identifier: "fizz", string: "buzz"),
    ]

    expected = <<-EXPECTED
<resources>
    <string name="foo">bar</string>
    <string name="chuck">norris</string>
    <string name="fizz">buzz</string>
</resources>
EXPECTED

    expect(
      Terrestrial::Cli::AndroidXmlFormatter.new(entries).format_foreign_translation
    ).to eq expected
  end
end

