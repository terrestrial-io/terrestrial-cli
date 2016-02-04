require 'spec_helper'

describe Terrestrial::Cli::Editor::Swift do

  it "adds a .translated to a string in a source line" do
    line = 'cell.menuItemLabel.text = "Ask Hacker News";'
    entry = double(:entry, 
       string: "Ask Hacker News",
       variables: [])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "Ask Hacker News".translated;'
  end

  it "does not modify a string that already has .translate" do
    line = 'cell.menuItemLabel.text = "Ask Hacker News".translated;'

    entry = double(:entry, 
       string: "Ask Hacker News",
       variables: [])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "Ask Hacker News".translated;'
  end

  it "transforms any strings that have variables in them" do
    line = 'cell.menuItemLabel.text = "\(foo) is crazy about \(bar)";'

    entry = double(:entry, 
       string: "\\(foo) is crazy about \\(bar)",
       variables: ["foo", "bar"])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = NSString(format: "%1$@ is crazy about %2$@".translated, foo, bar);'
  end
end
