require 'spec_helper'

describe Terrestrial::Cli::Editor::Swift do

  it "adds a .translated to a string in a source line" do
    line = 'cell.menuItemLabel.text = "Ask Hacker News";'
    entry = double(:entry, 
       string: "Ask Hacker News",
       context: nil, 
       variables: [])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "Ask Hacker News".translated;'
  end

  it "adds a function declaration with a cntxt field if cntxt is provided" do
    line = 'cell.menuItemLabel.text = "Ask Hacker News";'
    entry = double(:entry, 
       string: "Ask Hacker News",
       context: "Link to a website", 
       variables: [])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "Ask Hacker News".translatedWithContext("Link to a website");'
  end

  it "does not modify a string that already has .translate" do
    line = 'cell.menuItemLabel.text = "Ask Hacker News".translated;'

    entry = double(:entry, 
       string: "Ask Hacker News",
       context: nil,
       variables: [])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "Ask Hacker News".translated;'
  end

  it "does not modify a string that already has translatedWithContext" do
    line = 'cell.menuItemLabel.text = "Ask Hacker News".translatedWithContext("Link to a website");'

    entry = double(:entry, 
       string: "Ask Hacker News",
       context: "Link to a website",
       variables: [])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "Ask Hacker News".translatedWithContext("Link to a website");'
  end

  it "transforms any strings that have variables in them" do
    line = 'cell.menuItemLabel.text = "\(foo) is crazy about \(bar)";'

    entry = double(:entry, 
       string: "\\(foo) is crazy about \\(bar)",
       context: nil,
       variables: ["foo", "bar"])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = NSString(format: "%1$@ is crazy about %2$@".translated, foo, bar);'
  end

  it "transforms any strings that have variables and context in them" do
    line = 'cell.menuItemLabel.text = "\(foo) is crazy about \(bar)";'

    entry = double(:entry, 
       string: "\\(foo) is crazy about \\(bar)",
       context: "Some shocking context",
       variables: ["foo", "bar"])

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = NSString(format: "%1$@ is crazy about %2$@".translatedWithContext("Some shocking context"), foo, bar);'
  end
end
