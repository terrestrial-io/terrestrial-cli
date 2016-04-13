require 'spec_helper'

describe Terrestrial::Cli::Editor::Swift do

  it "adds a .translated to a string in a source line" do
    line = 'cell.menuItemLabel.text = "Ask Hacker News";'
    entry = double(:entry, 
       string: "Ask Hacker News",
       identifier: "ASK_HACKER_NEWS")

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "ASK_HACKER_NEWS".translated;'
  end

  it "does not modify a string that already has .translate" do
    line = 'cell.menuItemLabel.text = "ASK_HACKER_NEWS".translated;'

    entry = double(:entry, 
       string: "ASK_HACKER_NEWS",
       identifier: "something?")

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = "ASK_HACKER_NEWS".translated;'
  end

  it "transforms any strings that have variables in them" do
    line = 'cell.menuItemLabel.text = NSString(format: "%@ is crazy about %@", foo, bar);'

    entry = double(:entry, 
       string: "%@ is crazy about %@",
       identifier: "SOME_IDENTIFIER")

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = NSString(format: "SOME_IDENTIFIER".translated, foo, bar);'
  end

  it "transforms any strings that use Swift variables in them" do
    line = 'cell.menuItemLabel.text = "\(foo) is crazy about \(bar)";'

    entry = double(:entry, 
       string: "\\(foo) is crazy about \\(bar)",
       identifier: "SOME_IDENTIFIER")

    expect(
      Terrestrial::Cli::Editor::Swift.do_edit_string(line, entry)
    ).to eq 'cell.menuItemLabel.text = NSString(format: "SOME_IDENTIFIER".translated, foo, bar);'
  end

  context 'bug: backslashes - Too Short Escape Sequence' do
    it 'does not care about single backslashes' do
      line = 'cell.menuItemLabel.text = "\";'
      string = '\\'
      identifier = "EE"

      expect(
        Terrestrial::Cli::Editor::Swift.do_edit_string(line, double(:entry, string: string, identifier: identifier))
      ).to eq 'cell.menuItemLabel.text = "EE".translated;'
    end

    it 'does not care about single backslashes in words' do
      line = 'cell.menuItemLabel.text = "\this is a string";'
      string = '\this is a string'
      identifier = "EE"

      expect(
        Terrestrial::Cli::Editor::Swift.do_edit_string(line, double(:entry, string: string, identifier: identifier))
      ).to eq 'cell.menuItemLabel.text = "EE".translated;'
    end
  end
end
