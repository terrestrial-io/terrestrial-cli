require 'spec_helper'

describe Terrestrial::Cli::Editor::ObjC do

  it "adds a .translated to a string in a source line" do
    line = 'cell.menuItemLabel.text = @"Ask Hacker News";'
    string = "Ask Hacker News"
    identifier = "ASK_HACKER_NEWS"

    expect(
      Terrestrial::Cli::Editor::ObjC.do_edit_string(line, double(:entry, string: string, identifier: identifier))
    ).to eq 'cell.menuItemLabel.text = @"ASK_HACKER_NEWS".translated;'
  end

  it "does not modify a string that already has .translate" do
    line = 'cell.menuItemLabel.text = @"Ask Hacker News".translated;'
    string = "Ask Hacker News"
    identifier = "ASK_HACKER_NEWS"

    expect(
      Terrestrial::Cli::Editor::ObjC.do_edit_string(line, double(:entry, string: string, identifier: identifier))
    ).to eq 'cell.menuItemLabel.text = @"Ask Hacker News".translated;'
  end
end
