require 'spec_helper'

describe Terrestrial::Cli::Editor::ObjC do

  it "adds a .translated to a string in a source line" do
    line = 'cell.menuItemLabel.text = @"Ask Hacker News";'
    string = "Ask Hacker News"

    expect(
      Terrestrial::Cli::Editor::ObjC.do_edit_string(line, double(:entry, string: string, variables: []))
    ).to eq 'cell.menuItemLabel.text = @"Ask Hacker News".translated;'
  end

  it "adds ordering to variables in the strings" do
    line = 'cell.menuItemLabel.text = [NSString stringWithFormat: @"This is %@ in the %@", var1, var2];'
    string = "This is %@ in the %@"
    variables = ["var1", "var2"]

    expect(
      Terrestrial::Cli::Editor::ObjC.do_edit_string(line, double(:entry, string: string, variables: variables))
    ).to eq 'cell.menuItemLabel.text = [NSString stringWithFormat: @"This is %1$@ in the %2$@".translated, var1, var2];'
  end

  it "does not modify a string that already has .translate" do
    line = 'cell.menuItemLabel.text = @"Ask Hacker News".translated;'
    string = "Ask Hacker News"

    expect(
      Terrestrial::Cli::Editor::ObjC.do_edit_string(line, double(:entry, string: string, variables: []))
    ).to eq 'cell.menuItemLabel.text = @"Ask Hacker News".translated;'
  end

  it "does not modify a string that already has translatedWithContext" do
    line = 'cell.menuItemLabel.text = [@"Ask Hacker News" translatedWithContext: @"Link to a website"];'
    string = "Ask Hacker News"

    expect(
      Terrestrial::Cli::Editor::ObjC.do_edit_string(line, double(:entry, string: string, variables: []))
    ).to eq 'cell.menuItemLabel.text = [@"Ask Hacker News" translatedWithContext: @"Link to a website"];'

    expect(
      Terrestrial::Cli::Editor::ObjC.do_edit_string(line, double(:entry, string: string, variables: []))
    ).to eq 'cell.menuItemLabel.text = [@"Ask Hacker News" translatedWithContext: @"Link to a website"];'
  end
end
