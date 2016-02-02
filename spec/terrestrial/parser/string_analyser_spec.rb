require 'spec_helper'

def example_file(name)
  "spec/fixtures/" + name
end

describe Terrestrial::Cli::Parser::StringAnalyser do

  it "finds the percentage of non alphanumeric characters in a string" do
    expect(
      Terrestrial::Cli::Parser::StringAnalyser.new("abcdeghij#", :swift).percentage_of_none_alphanumeric
    ).to eq 0.1

    expect(
      Terrestrial::Cli::Parser::StringAnalyser.new("£!@*&£^*", :swift).percentage_of_none_alphanumeric
    ).to eq 1.0
  end

  it "says if a string is camel case" do
    expect(
      Terrestrial::Cli::Parser::StringAnalyser.new("snake_case word", :swift).has_snake_case_words?
    ).to eq true

    expect(
      Terrestrial::Cli::Parser::StringAnalyser.new("herpty derpty", :swift).has_snake_case_words?
    ).to eq false
  end

  context "variables" do
    it "can ignore variables in strings" do
      string = "That's a %@ %@ from %d!"
      language = Terrestrial::Cli::Parser::ObjC::LANGUAGE
      variables = ["make", "model", "year"]

      expect(Terrestrial::Cli::Parser::StringAnalyser.is_string_for_humans?(string, language, variables)).to eq true
    end

    it "does not think single variables are for humans" do
      string = "%@"
      language = Terrestrial::Cli::Parser::ObjC::LANGUAGE
      variables = ["name"]

      expect(Terrestrial::Cli::Parser::StringAnalyser.is_string_for_humans?(string, language, variables)).to eq false
    end

    it "handles the weird swift syntax" do
      string = "That is a \\(make) \\(model) from \\(year)!"
      language = Terrestrial::Cli::Parser::Swift::LANGUAGE
      variables = ["make", "model", "year"]

      expect(Terrestrial::Cli::Parser::StringAnalyser.is_string_for_humans?(string, language, variables)).to eq true
    end

    it "handles the weird android syntax" do
      string = "This is my %1$d and %2$f" 
      language = Terrestrial::Cli::Parser::AndroidXML::LANGUAGE
      variables = ["%1$d", "%2$f"]

      expect(Terrestrial::Cli::Parser::StringAnalyser.is_string_for_humans?(string, language, variables)).to eq true
    end
  end
end
