require 'spec_helper'

def example_file(name)
  "spec/fixtures/" + name
end

Parser = Terrestrial::Cli::Parser::ObjC

describe Terrestrial::Cli::Parser::ObjC do
  context "#analyse_line_for_strings" do
    it "finds strings in a line and returns a NewStringEntry" do
      line = 'self.foo = @"This is a random string that should not show up";'
      index = 3
      file_name  = "foo.m"

      result = Parser.analyse_line_for_strings(line, index, file_name)
      expect(result.count).to eq 1
      expect(result[0]["string"]).to eq "This is a random string that should not show up"
      expect(result[0]["line_number"]).to eq 4
      expect(result[0]["file"]).to eq "foo.m"
      expect(result[0]["type"]).to eq "unknown"
    end

    it "finds strings in a line and returns a NewStringEntry" do
      line = 'NSString *message = [NSString stringWithFormat:@"That\'s a %@ %@ from %d!", make, model, year];'
      index = 3
      file_name  = "foo.m"

      result = Parser.analyse_line_for_strings(line, index, file_name)
      expect(result.count).to eq 1
      expect(result[0]["string"]).to eq "That's a %@ %@ from %d!"
      expect(result[0]["line_number"]).to eq 4
      expect(result[0]["file"]).to eq "foo.m"
      #expect(result[0]["has_variables"]?).to eq true
      #expect(result[0]["variables"]).to eq ["make", "model", "year"]
    end

    it "ignores NSLocalizedString calls" do
      line = 'NSString *message = NSLocalizedString(@"Username", nil);'
      index = 3
      file_name  = "foo.m"

      result = Parser.analyse_line_for_strings(line, index, file_name)
      expect(result).to eq []
    end

    it "ignores .translated calls" do
      line = 'NSString *message = @"Username".translated;'
      index = 3
      file_name  = "foo.m"

      result = Parser.analyse_line_for_strings(line, index, file_name)
      expect(result).to eq []
    end
  end

  context "#analyse_line_for_dot_translated" do
    it "finds all instances of .translated in the line" do
      line = 'self.title = @"This is followed by .translated".translated;'
      index = 3
      file_name  = "foo.m"

      result = Parser.analyse_line_for_dot_translated(line, index, file_name)
      expect(result.count).to eq 1
      expect(result[0]["string"]).to eq "This is followed by .translated"
      expect(result[0]["line_number"]).to eq 4
      expect(result[0]["file"]).to eq "foo.m"
      expect(result[0]["type"]).to eq ".translated"
    end

    it "finds all instances of translatedWithContext in the line" do
      line = 'self.title = [@"This is wrapped in a translatedWithContext call" translatedWithContext: @"Table setting. For lunch."];'
      index = 7
      file_name  = "foo.m"

      result = Parser.analyse_line_for_translatedWithContext(line, index, file_name)
      expect(result.count).to eq 1
      expect(result[0]["string"]).to eq "This is wrapped in a translatedWithContext call"
      expect(result[0]["line_number"]).to eq 8
      expect(result[0]["file"]).to eq "foo.m"
      expect(result[0]["type"]).to eq "translatedWithContext"
    end

    it "handles cases where there is not space between translatedWithContext and the string" do
      line = '[_startButton setTitle:[@"GET STARTED" translatedWithContext:@"Some context!"] forState:UIControlStateNormal];'
      index = 7
      file_name  = "foo.m"

      result = Parser.analyse_line_for_translatedWithContext(line, index, file_name)
      expect(result.count).to eq 1
      expect(result[0]["string"]).to eq "GET STARTED"
      expect(result[0]["context"]).to eq "Some context!"
      expect(result[0]["line_number"]).to eq 8
      expect(result[0]["file"]).to eq "foo.m"
      expect(result[0]["type"]).to eq "translatedWithContext"
    end
  end

  context "#find_api_calls" do
    it "finds multiple matches from one line" do
      expect(
        Parser.find_api_calls(example_file("MultipleApiCallsOneLineViewController.m")))
      .to eq [
        {
          "file" => "spec/fixtures/MultipleApiCallsOneLineViewController.m",
          "line_number" => 13,
          "string" => "Home",
          "context" => "",
          "type" => ".translated",
        },
        {
          "file" => "spec/fixtures/MultipleApiCallsOneLineViewController.m",
          "line_number" => 13,
          "string" => "History",
          "context" => "",
          "type" => ".translated",
        },
        {
          "file" => "spec/fixtures/MultipleApiCallsOneLineViewController.m",
          "line_number" => 13,
          "string" => "Settings",
          "type" => "translatedWithContext",
          "context" => "Table setting. For lunch."
        }
      ]
    end
  end

  context "#looks_suspicious" do
    it "only checks the line without the matched string" do
      line = %{  this is my line @"NSLog" } 

      expect(Terrestrial::Cli::Parser::ObjC.looks_suspicious(line)).to eq false
    end
  end

  context "get_variables_names" do
    it "finds the names of variables in stringWithFormat calls" do
      line = 'NSString *message = [NSString stringWithFormat:@"That\'s a %@ %@ from %d!", make, model, year];'

      expect(Terrestrial::Cli::Parser::ObjC.get_variable_names(line)).to eq ["make", "model", "year"]
    end
  end
end
