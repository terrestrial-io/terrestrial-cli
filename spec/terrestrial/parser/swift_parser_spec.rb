SwiftParser = Terrestrial::Cli::Parser::Swift

describe Terrestrial::Cli::Parser::Swift do
  context "#analyse_line_for_strings" do
    it "finds strings in a line and returns a NewStringEntry" do
      line = 'label.text = "Create your first routine below."'
      index = 3
      file_name  = "foo.swift"

      result = SwiftParser.analyse_line_for_strings(line, index, file_name)
      expect(result.count).to eq 1
      expect(result[0].class).to eq Terrestrial::Cli::Bootstrapper::NewStringEntry
      expect(result[0].string).to eq "Create your first routine below."
      expect(result[0].line_number).to eq 4
      expect(result[0].file).to eq "foo.swift"
      expect(result[0].type).to eq "unknown"
    end
    
    it "finds strings with variables in it" do
      line = 'label.text = "Hello \(something) \(world)."'
      index = 3
      file_name  = "foo.swift"

      result = SwiftParser.analyse_line_for_strings(line, index, file_name)
      expect(result.count).to eq 1
      expect(result[0].class).to eq Terrestrial::Cli::Bootstrapper::NewStringEntry
      expect(result[0].string).to eq "Hello \\(something) \\(world)."
      expect(result[0].line_number).to eq 4
      expect(result[0].file).to eq "foo.swift"
      expect(result[0].type).to eq "stringWithFormat"
      # expect(result[0].variables).to eq ["something", "world"]
    end
  end

  context "#looks_suspicious" do
    it "only checks the line without the matched string" do
      line = %{  this is my line @"NSLog" } 

      expect(Terrestrial::Cli::Parser::Swift.looks_suspicious(line)).to eq false
    end
  end
end
